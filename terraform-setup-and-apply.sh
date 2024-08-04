#!/bin/bash

# Define text colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to install Terraform
install_terraform() {
    if [ -f /etc/fedora-release ]; then
        echo -e "${YELLOW}[INFO] Detected Fedora. Installing Terraform...${NC}"
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        sudo dnf -y install terraform
    elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
        echo -e "${YELLOW}[INFO] Detected Ubuntu. Installing Terraform...${NC}"
        sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
        curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
        sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
        sudo apt-get update && sudo apt-get install -y terraform
    else
        echo -e "${RED}[ERROR] Unsupported OS. Only Fedora and Ubuntu are supported.${NC}"
        exit 1
    fi
}

# Function to install tfsec
install_tfsec() {
    echo -e "${YELLOW}[INFO] Installing tfsec...${NC}"
    if [ -f /etc/fedora-release ]; then
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
        curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
    else
        echo -e "${RED}[ERROR] Unsupported OS for tfsec installation. Only Fedora and Ubuntu are supported.${NC}"
        exit 1
    fi
}

# Function to select deployment folder
select_deployment_folder() {
    local environment_path=$1
    local deployments=($(find "$environment_path" -maxdepth 1 -type d \( -name 'apps' -o -name 'cluster' \)))

    if [ ${#deployments[@]} -eq 0 ]; then
        echo -e "${RED}[ERROR] No deployment folders (apps or cluster) found in ${environment_path}.${NC}"
        exit 1
    elif [ ${#deployments[@]} -eq 1 ]; then
        echo -e "${YELLOW}[INFO] Found one deployment folder: ${deployments[0]}.${NC}"
        echo "${deployments[0]}"
    else
        echo -e "${YELLOW}[PROMPT] Multiple deployment folders found. Please select one:${NC}"
        select deployment in "${deployments[@]}"; do
            if [ -n "$deployment" ]; then
                echo "$deployment"
                break
            else
                echo -e "${RED}[ERROR] Invalid selection.${NC}"
            fi
        done
    fi
}

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${YELLOW}[INFO] Terraform not found. Installing Terraform...${NC}"
    install_terraform

    # Verify installation
    if ! command -v terraform &> /dev/null; then
        echo -e "${RED}[ERROR] Terraform installation failed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[SUCCESS] Terraform installed successfully.${NC}"
else
    echo -e "${GREEN}[INFO] Terraform is already installed.${NC}"
fi

# Check if tfsec is installed
if ! command -v tfsec &> /dev/null; then
    echo -e "${YELLOW}[INFO] tfsec not found. Installing tfsec...${NC}"
    install_tfsec

    # Verify installation
    if ! command -v tfsec &> /dev/null; then
        echo -e "${RED}[ERROR] tfsec installation failed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}[SUCCESS] tfsec installed successfully.${NC}"
else
    echo -e "${GREEN}[INFO] tfsec is already installed.${NC}"
fi

# Set the base directory based on the environment
if [ "$ENV" == "test" ]; then
    BASE_DIR="infrastructure/environments/test"
    ENV_NAME="Test"
elif [ "$ENV" == "dev" ]; then
    BASE_DIR="infrastructure/environments/dev"
    ENV_NAME="Development"
else
    echo -e "${RED}[ERROR] Environment not set or unsupported. Please set ENV to 'test' or 'dev'.${NC}"
    exit 1
fi

# Set the working directory based on DEPLOY variable or prompt user to select
if [ -n "$DEPLOY" ]; then
    WORKING_DIR="$BASE_DIR/$DEPLOY"
    if [ ! -d "$WORKING_DIR" ]; then
        echo -e "${RED}[ERROR] The specified deployment folder '${DEPLOY}' does not exist in ${BASE_DIR}.${NC}"
        exit 1
    fi
    echo -e "${YELLOW}[INFO] Using specified deployment folder: ${WORKING_DIR}${NC}"
else
    WORKING_DIR=$(select_deployment_folder "$BASE_DIR")
fi

VAR_FILE="-var-file=terraform.tfvars"

echo -e "${YELLOW}[INFO] Environment: ${ENV_NAME}${NC}"
echo -e "${YELLOW}[INFO] Using directory: ${WORKING_DIR}${NC}"

# Initialize Terraform
echo -e "${YELLOW}[INFO] Initializing Terraform…${NC}"
terraform -chdir=${WORKING_DIR} init

# Check if terraform init was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] Terraform initialization completed.${NC}"
else
    echo -e "${RED}[ERROR] Terraform initialization failed.${NC}"
    exit 1
fi

# Format Terraform files
echo -e "${YELLOW}[INFO] Formatting Terraform files…${NC}"
terraform -chdir=${WORKING_DIR} fmt -recursive

# Validate Terraform configuration
echo -e "${YELLOW}[INFO] Validating Terraform configuration…${NC}"
terraform -chdir=${WORKING_DIR} validate

# Check if terraform validate was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] Terraform configuration is valid.${NC}"
else
    echo -e "${RED}[ERROR] Terraform configuration is invalid.${NC}"
    exit 1
fi

# Run tfsec security analysis after validation
echo -e "${YELLOW}[INFO] Running tfsec security analysis on ${ENV_NAME} environment…${NC}"
tfsec ${WORKING_DIR} --concise-output --exclude=AWS001,AWS002

# Check if tfsec was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] tfsec analysis completed successfully.${NC}"
else
    echo -e "${RED}[ERROR] tfsec analysis failed.${NC}"
    exit 1
fi

# Check if the -only-validate flag is set
if [ "$1" == "-only-validate" ]; then
    echo -e "${YELLOW}[INFO] Skipping Terraform plan and apply steps due to -only-validate flag.${NC}"
    exit 0
fi

# Generate Terraform plan
echo -e "${YELLOW}[INFO] Generating Terraform plan…${NC}"
terraform -chdir=${WORKING_DIR} plan -out=tfplan ${VAR_FILE}

# Check if terraform plan was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS] Terraform plan generated successfully.${NC}"
else
    echo -e "${RED}[ERROR] Failed to generate Terraform plan.${NC}"
    exit 1
fi

# Ask user if they want to apply the plan
echo -e "${YELLOW}[PROMPT] Do you want to apply this plan? (yes/no)${NC}"
read answer
if [ "$answer" == "yes" ]; then
    # Apply the Terraform plan
    echo -e "${YELLOW}[INFO] Applying Terraform plan…${NC}"
    terraform -chdir=${WORKING_DIR} apply "tfplan"

    # Check if terraform apply was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[SUCCESS] Terraform apply completed.${NC}"
    else
        echo -e "${RED}[ERROR] Terraform apply failed.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[INFO] Apply operation cancelled by user.${NC}"
fi
