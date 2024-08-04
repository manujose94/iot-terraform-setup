# 🛠️ Terraform Environment Setup

![Terraform](https://img.shields.io/badge/Terraform-Infrastructure%20as%20Code-623CE4?logo=terraform)
![Environment](https://img.shields.io/badge/Environment-Dev%20%7C%20Test-green)
![License](https://img.shields.io/badge/License-MIT-blue)

## 📖 Overview

`terraform-environment-setup` is a repository designed to manage Terraform configurations for multiple environments. It includes reusable modules, resource-specific configurations, and an automation script to simplify the setup and deployment process. The basis for managing an IOT-focused infrastructure.

## ✨ Features

- **🚀 Automatic Terraform Installation**: Ensures Terraform is installed on the system.
- **🏗️ Environment-Specific Configuration**: Separate directories for development (`dev/`) and test (`test/`) environments.
- **📦 Reusable Modules**: Modular design for EKS, network, and VPC configurations.
- **🔧 Resource Management**: Organized resource configurations for EC2, S3, and security groups.
- **🤖 Automation Script**: A comprehensive script to initialize, validate, plan, and apply Terraform configurations.
- **🧪 LocalStack Integration**: Uses LocalStack for testing in the test environment.

## 🏁 Getting Started

### ✅ Prerequisites

- **🖥️ Operating System**: Fedora or Ubuntu
- **🛠️ LocalStack**: For the `test` environment and local testing

---

## 🛠️ Automation Script

### terraform-setup-and-apply.sh

A comprehensive script to automate the setup, initialization, validation, and application of Terraform configurations. The script handles the following:

- **🔍 Automatic Installation**: Installs `Terraform` and `tfsec` if not present.
- **🌐 Environment Detection**: Detects and sets the working directory based on the `ENV` variable (`dev` or `test`).
- **📁 Deployment Folder Selection**: If multiple deployment folders (e.g., `apps` or `cluster`) are found, the script either uses the `DEPLOY` variable to select one or prompts the user to choose.
- **⚙️ Initialization**: Initializes the Terraform working directory.
- **🧹 Formatting and Validation**: Formats and validates the Terraform configuration.
- **🔒 Security Analysis**: Runs `tfsec` to perform a security analysis of the Terraform configuration.
- **📝 Plan Generation and Application**: Generates a Terraform plan and optionally applies it based on user confirmation.

### 🚀 Start

1. **📦 Clone the Repository**:
   ```sh
   git clone https://github.com/yourusername/terraform-environment-setup.git
   cd terraform-environment-setup
   ```

2. **🛠️ Test Locally with LocalStack (Optional) - Start LocalStack**:
   ```sh
   docker-compose --profile localstack up -d
   ```

3. **🔑 Ensure the Script Has Execution Permissions**:
   ```sh
   chmod +x terraform-setup-and-apply.sh
   ```

### 💻 Running the Script

4. **▶️ Run the Script with the Desired Environment**:
   - To deploy in the `test` environment:
     ```sh
     ENV=test ./terraform-setup-and-apply.sh
     ```
   - To deploy in the `dev` environment:
     ```sh
     ENV=dev ./terraform-setup-and-apply.sh
     ```

5. **📂 Specify the Deployment Folder**:
   - If you want to target a specific deployment folder (`apps` or `cluster`), use the `DEPLOY` variable:
     ```sh
     ENV=test DEPLOY=apps ./terraform-setup-and-apply.sh
     ```
     or
     ```sh
     ENV=dev DEPLOY=cluster ./terraform-setup-and-apply.sh
     ```
   - If the `DEPLOY` variable is not set, the script will prompt you to choose a deployment folder if more than one is available.

6. **🛡️ Optionally, Validate the Terraform Configuration Without Planning or Applying Changes**:
   - Add the `-only-validate` flag to any of the above commands:
     ```sh
     ENV=test DEPLOY=apps ./terraform-setup-and-apply.sh -only-validate
     ```
     or
     ```sh
     ENV=dev DEPLOY=cluster ./terraform-setup-and-apply.sh -only-validate
     ```
   - For the default environment (if no specific deployment folder is required):
     ```sh
     ./terraform-setup-and-apply.sh -only-validate
     ```

### 📋 Example Output

```sh
[INFO] Terraform not found. Installing Terraform...
[INFO] Detected Ubuntu. Installing Terraform...
[SUCCESS] Terraform installed successfully.
[INFO] tfsec not found. Installing tfsec...
[SUCCESS] tfsec installed successfully.
[INFO] Environment: Test
[INFO] Using directory: infrastructure/environments/test/apps
[INFO] Initializing Terraform…
[SUCCESS] Terraform initialization completed.
[INFO] Formatting Terraform files…
[INFO] Validating Terraform configuration…
[SUCCESS] Terraform configuration is valid.
[INFO] Running tfsec security analysis on Test environment…
[SUCCESS] tfsec analysis completed successfully.
[INFO] Generating Terraform plan…
[SUCCESS] Terraform plan generated successfully.
[PROMPT] Do you want to apply this plan? (yes/no)
```

---

## 🧪 LocalStack for Test Environment

The test environment uses LocalStack to simulate AWS services locally. This allows you to test your infrastructure changes without incurring costs or affecting live environments.

### 🔧 Usage

1. **▶️ Start LocalStack**:
   ```sh
   docker-compose --profile localstack up -d
   ```

2. **💻 Run the script**:
   ```sh
   ENV=test ./terraform-setup-and-apply.sh
   ```

### 🌐 Terraform and `tfsec`:

1. **⚙️ Initialize Terraform**:
   After LocalStack is up, you can initialize Terraform:
   ```sh
   docker-compose run --rm terraform
   ```

2. **🔒 Run the `tfsec`**:
   Finally, run `tfsec` to scan the Terraform configuration:
   ```sh
   docker-compose run --rm tfsec
   ```

> **Note:** When running Terraform commands (`terraform plan`, `terraform apply`), ensure your Terraform configuration points to the LocalStack endpoints, as mentioned above in the provider configuration.

## 📄 License

This project is licensed under the MIT License.

---

Feel free to contribute and raise issues on GitHub to help improve this project.
