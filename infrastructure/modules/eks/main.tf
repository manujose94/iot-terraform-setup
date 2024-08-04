module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "${var.environment}-cloudiot-eks"
  cluster_version = "1.29"
  version         = "~> 19.0"
  //Cluster is set on private subnets not directly accessible from the internet
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  cluster_endpoint_private_access = true
  // Cluster is set on public subnets accessible from the internet
  cluster_endpoint_public_access = true
  // Pro Tip: Use "cluster_endpoint_public_access = false" to make the cluster private
  // Then Use VPN Gateway to access the cluster
  cluster_create_timeout = "30m"
  cluster_delete_timeout = "15m"
  cluster_addons = {
    vpc_cni = {
      enabled           = true
      resolve_conflicts = "overwrite"
    }
    kube_proxy = {
      enabled           = true
      resolve_conflicts = "overwrite"
    }
    coredns = {
      enabled           = true
      resolve_conflicts = "overwrite"
    }
    csi = {
      enabled           = true
      resolve_conflicts = "overwrite"
    }
  }
  manage_aws_auth_configmap = true
  eks_managed_node_groups = {
    node-group = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1
      instance_type    = "t3.nano"

      tags = {
        "Terraform"   = "true"
        "Environment" = "dev"
      }
    }
  }

  //Allow Terraform to access the EKS cluster
  data "aws_eks_cluster" "cluster" {
    name = module.eks.cluster_name
  }

  data "aws_eks_cluster_auth" "cluster" {
    name = module.eks.cluster_name
  }

  provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    load_config_file       = false
  }

  tags = {
    "Terraform"   = "true"
    "Environment" = var.environment
  }
}