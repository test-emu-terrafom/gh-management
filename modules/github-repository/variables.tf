variable "name" {
  description = "Repository name"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Repository name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "description" {
  description = "Repository description"
  type        = string
}

variable "visibility" {
  description = "Repository visibility"
  type        = string
  default     = "private"
  
  validation {
    condition     = contains(["private", "internal", "public"], var.visibility)
    error_message = "Repository visibility must be 'private', 'internal', or 'public'."
  }
}