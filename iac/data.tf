# Data source to validate EntraID groups are synced to GitHub
data "github_organization_external_groups" "all" {}

# Create a map of external groups for easy lookup
locals {
  external_groups_map = {
    for group in data.github_organization_external_groups.all.groups :
    group.name => group
  }
}