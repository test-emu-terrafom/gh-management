variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_team_prefix" {
  description = "Prefix for GitHub team names"
  type        = string
  default     = "GH-"
}

variable "github_app_id" {
  description = "GitHub App ID for authentication"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID"
  type        = string
}

variable "github_app_pem_file" {
  description = "Path to GitHub App private key"
  type        = string
  sensitive   = true
}

variable "everyone_team_enabled" {
  description = "Whether to create and assign an 'Everyone' team with read access"
  type        = bool
  default     = true
}

variable "everyone_team_name" {
  description = "Name of the team that gets read access to all repositories"
  type        = string
  default     = "SG-Everyone"
}

variable "default_repository_visibility" {
  description = "Default visibility for new repositories"
  type        = string
  default     = "private"
  
  validation {
    condition     = contains(["private", "internal", "public"], var.default_repository_visibility)
    error_message = "Repository visibility must be 'private', 'internal', or 'public'."
  }
}

variable "enable_vulnerability_alerts" {
  description = "Enable vulnerability alerts for all repositories"
  type        = bool
  default     = true
}

variable "enable_automated_security_fixes" {
  description = "Enable automated security fixes for all repositories"
  type        = bool
  default     = true
}

variable "require_pr_reviews" {
  description = "Require PR reviews for protected branches"
  type        = bool
  default     = true
}

variable "required_approving_reviews" {
  description = "Number of required approving reviews"
  type        = number
  default     = 1
}

variable "dismiss_stale_reviews" {
  description = "Dismiss stale PR reviews when new commits are pushed"
  type        = bool
  default     = true
}

variable "require_code_owner_reviews" {
  description = "Require review from CODEOWNERS"
  type        = bool
  default     = true
}

variable "enforce_admins" {
  description = "Enforce branch protection rules for administrators"
  type        = bool
  default     = true
}


variable "enable_emu_features" {
  description = "Enable EMU-specific features (disable for testing)"
  type        = bool
  default     = true
}