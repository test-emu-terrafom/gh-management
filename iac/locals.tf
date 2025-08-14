locals {
  # Parse JSON configuration
  config = jsondecode(file("${path.module}/../config/github-resources.json"))
  
  # Transform teams list with GitHub naming convention
  teams = {
    for team in local.config.teams : team => {
      name        = team
      github_name = "${var.github_team_prefix}${team}"
      description = "Team synced from EntraID group ${team}"
    }
  }
  
  # Transform repositories with default values
  repositories = {
    for repo in local.config.repositories : repo.name => {
      name        = repo.name
      description = repo.description
      visibility  = try(repo.visibility, "private")
      permissions = {
        for perm in repo.team_permissions : 
        perm.team => perm.permission
      }
    }
  }
  
  # Flatten team-repo permissions for easy iteration
  team_repo_permissions = flatten([
    for repo_name, repo in local.repositories : [
      for team_name, permission in repo.permissions : {
        key        = "${team_name}-${repo_name}"
        repo_name  = repo_name
        team_name  = team_name
        permission = permission
      }
    ]
  ])
  
  # Handle external groups conditionally
  # In production (EMU): maps EntraID groups to GitHub external groups
  # In testing: empty map since external groups don't exist
  external_groups_map = var.enable_emu_features && length(data.github_organization_external_groups.all) > 0 ? {
    for group in data.github_organization_external_groups.all[0].groups :
    group.name => group
  } : {}
}