output "team_id" {
  description = "The ID of the created team"
  value       = github_team.team.id
}

output "team_slug" {
  description = "The slug of the created team"
  value       = github_team.team.slug
}

output "team_node_id" {
  description = "The node ID of the created team"
  value       = github_team.team.node_id
}