output "repository_id" {
  description = "The ID of the repository"
  value       = github_repository.repo.repo_id
}

output "repository_name" {
  description = "The name of the repository"
  value       = github_repository.repo.name
}

output "repository_url" {
  description = "The HTTP URL of the repository"
  value       = github_repository.repo.html_url
}

output "repository_node_id" {
  description = "The node ID of the repository"
  value       = github_repository.repo.node_id
}