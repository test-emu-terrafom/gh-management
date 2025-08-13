resource "github_team" "team" {
  name        = var.team_name
  description = var.description
  privacy     = "closed"
  
  # Link to EntraID external group for EMU
  parent_team_id = var.external_group_id
}

# Optional: Create team settings
resource "github_team_settings" "settings" {
  count = var.enable_team_discussions ? 1 : 0
  
  team_id = github_team.team.id
  
  review_request_delegation {
    algorithm    = "ROUND_ROBIN"
    member_count = 2
    notify       = true
  }
}