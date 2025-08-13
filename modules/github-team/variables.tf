variable "team_name" {
  description = "The name of the team (with prefix)"
  type        = string
}

variable "display_name" {
  description = "The display name of the team (EntraID group name)"
  type        = string
}

variable "description" {
  description = "The description of the team"
  type        = string
}

variable "entraid_group" {
  description = "The EntraID group name"
  type        = string
}

variable "external_group_id" {
  description = "The external group ID from SCIM sync"
  type        = string
}

variable "enable_team_discussions" {
  description = "Enable team discussions"
  type        = bool
  default     = false
}