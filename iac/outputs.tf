output "teams_created" {
  description = "Map of teams created with their IDs"
  value = {
    for name, team in module.teams : name => {
      id   = team.team_id
      slug = team.team_slug
      url  = "https://github.com/orgs/${var.github_organization}/teams/${team.team_slug}"
    }
  }
}

output "repositories_created" {
  description = "Map of repositories created with their URLs"
  value = {
    for name, repo in module.repositories : name => {
      name = repo.repository_name
      url  = repo.repository_url
    }
  }
}

output "team_repository_assignments" {
  description = "Summary of team permissions assigned"
  value = {
    for perm in local.team_repo_permissions : perm.key => {
      team       = perm.team_name
      repository = perm.repo_name
      permission = perm.permission
    }
  }
}

output "external_groups_status" {
  description = "Status of EntraID group synchronization"
  value = {
    for name, group in local.external_groups_map : name => {
      id      = group.id
      synced  = true
      updated = group.updated_at
    }
  }
}