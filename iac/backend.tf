terraform {
  backend "azurerm" {
    resource_group_name  = "rg-github-test"
    storage_account_name = "stgithubtest26549"  # Update this!
    container_name       = "tfstate"
    key                  = "github-test.tfstate"
    # use_oidc            = true
  }
}