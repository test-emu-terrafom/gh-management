resource "github_team_repository" "access" {
  team_id    = var.team_id
  repository = var.repository
  permission = var.permission
}