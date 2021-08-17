terraform {
  backend "remote" {
    organization = "Harika"

    workspaces {
      name = "prod-DEPLOYMENT"
    }
  }
}