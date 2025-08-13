output "id" {
  description = "The ID of the team repository association"
  value       = github_team_repository.access.id
}

output "permission" {
  description = "The permission level granted"
  value       = github_team_repository.access.permission
}