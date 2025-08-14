# Local backend for testing without Azure
terraform {
  backend "local" {
    path = "../terraform-test.tfstate"
  }
}