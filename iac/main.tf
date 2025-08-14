# Validate all teams have corresponding external groups
# resource "null_resource" "validate_external_groups" {
#   for_each = local.teams
  
#   lifecycle {
#     precondition {
#       condition     = can(local.external_groups_map[each.key])
#       error_message = "EntraID group '${each.key}' not found in GitHub. Ensure SCIM provisioning is enabled and the group is assigned to the GitHub EMU app."
#     }
#   }
# }
resource "null_resource" "validate_external_groups" {
  for_each = var.enable_emu_features ? local.teams : {}
  
  lifecycle {
    precondition {
      condition     = can(local.external_groups_map[each.key])
      error_message = "EntraID group '${each.key}' not found in GitHub."
    }
  }
}

# Create GitHub teams linked to EntraID groups
module "teams" {
  source = "../modules/github-team"
  
  for_each = local.teams
  
  team_name     = each.value.github_name
  display_name  = each.key
  description   = each.value.description
  entraid_group = each.key
  # external_group_id = local.external_groups_map[each.key].id
  external_group_id = var.enable_emu_features ? local.external_groups_map[each.key].id : null
  
  # depends_on = [null_resource.validate_external_groups]
  depends_on = var.enable_emu_features ? [null_resource.validate_external_groups] : []
}

# Create repositories
module "repositories" {
  source = "../modules/github-repository"
  
  for_each = local.repositories
  
  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility
}

# Assign team permissions to repositories
module "team_permissions" {
  source = "../modules/team-repository-access"
  
  for_each = {
    for perm in local.team_repo_permissions : perm.key => perm
  }
  
  team_id    = module.teams[each.value.team_name].team_id
  repository = module.repositories[each.value.repo_name].repository_name
  permission = each.value.permission
  
  depends_on = [module.teams, module.repositories]
}

# Always assign Everyone team read access to all repos
module "everyone_access" {
  source = "../modules/team-repository-access"
  
  for_each = var.everyone_team_enabled ? local.repositories : {}
  
  team_id    = module.teams[var.everyone_team_name].team_id
  repository = module.repositories[each.key].repository_name
  permission = "pull"
  
  depends_on = [module.teams, module.repositories]
}