data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "Harika"
    workspaces = {
      name = "50-EKS"
    }
  }
}
data "terraform_remote_state" "mssql" {
  backend = "remote"

  config = {
    organization = "Harika"
    workspaces = {
      name = "45-MSSQL"
    }
  }
}
data "terraform_remote_state" "ecr" {
  backend = "remote"

  config = {
    organization = "Harika"
    workspaces = {
      name = "30-ECR"
    }
  }
}

data "terraform_remote_state" "iam" {
  backend = "remote"

  config = {
    organization = "Harika"
    workspaces = {
      name = "05-IAM"
    }
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.cluster.outputs.cluster_id
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.cluster.outputs.cluster_endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = data.terraform_remote_state.cluster.outputs.cluster_ca_certificate
}

locals {
  registry_server = "https://${data.terraform_remote_state.ecr.outputs.ecr_registry_id}.dkr.ecr.us-west-2.amazonaws.com"
  image_name = "${data.terraform_remote_state.ecr.outputs.ecr_repository_url}:${var.docker_build_tag}"  
}
