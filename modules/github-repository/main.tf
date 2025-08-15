resource "github_repository" "repo" {
  name                   = var.name
  description           = var.description
  visibility            = var.visibility
  
  has_issues            = true
  has_discussions       = false
  has_projects          = false
  has_wiki              = false
  
  allow_merge_commit    = true
  allow_squash_merge    = true
  allow_rebase_merge    = false
  allow_auto_merge      = true
  delete_branch_on_merge = true
  
  vulnerability_alerts   = true
  
  # security_and_analysis {
  #   secret_scanning {
  #     status = "enabled"
  #   }
  #   secret_scanning_push_protection {
  #     status = "enabled"
  #   }
  # }
}

resource "github_branch_protection" "main" {
  repository_id = github_repository.repo.node_id
  pattern       = "main"
  
  enforce_admins = true
  
  required_status_checks {
    strict = true
  }
  
  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}