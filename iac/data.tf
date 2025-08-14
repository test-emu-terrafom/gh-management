# Data source to validate EntraID groups are synced to GitHub (EMU only)
data "github_organization_external_groups" "all" {
  count = var.enable_emu_features ? 1 : 0
}