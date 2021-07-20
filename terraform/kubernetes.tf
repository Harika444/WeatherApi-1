data "terraform_remote_state" "cluster" {
  backend = "remote"

  config = {
    organization = "Harika"
    workspaces = {
      name = "my-CLUSTER"
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
  registry_server = "https://${data.terraform_remote_state.cluster.outputs.ecr_registry_id}.dkr.ecr.us-west-2.amazonaws.com"
  image_name = "${data.terraform_remote_state.cluster.outputs.ecr_repository_url}:${var.latest}"
}