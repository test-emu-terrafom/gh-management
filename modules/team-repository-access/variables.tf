variable "team_id" {
  description = "The ID of the team"
  type        = string
}

variable "repository" {
  description = "The repository name"
  type        = string
}

variable "permission" {
  description = "The permission level (pull, push, maintain, admin)"
  type        = string
  
  validation {
    condition     = contains(["pull", "push", "maintain", "admin"], var.permission)
    error_message = "Permission must be one of: pull, push, maintain, admin."
  }
}