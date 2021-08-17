terraform {
  backend "remote" {
    organization = "Harika"

    workspaces {
      name = "dev-DEPLOYMENT"
    }
  }
}