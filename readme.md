# GitHub EMU Management with Terraform

This repository manages GitHub Enterprise Managed Users (EMU) teams and repositories using Terraform and a GitOps workflow.

## Overview

- **Source of Truth**: `config/github-resources.json`
- **Authentication**: OIDC with Azure AD
- **Team Management**: Automated linking to EntraID groups
- **Repository Management**: Consistent configuration and permissions

## Prerequisites

1. **GitHub Enterprise with EMU enabled**
2. **Azure AD (EntraID) configured with**:
   - GitHub EMU application
   - SCIM provisioning enabled
   - Security groups created
3. **GitHub App** with permissions:
   - Administration: Read & Write
   - Members: Read & Write
   - Metadata: Read
4. **Azure Storage Account** for Terraform state
5. **Service Principal** with:
   - Storage Blob Data Contributor on storage account
   - Microsoft Graph API permissions (optional, for automation)

## Directory Structure
```
terraform-github-emu/
├── .github/workflows/    # CI/CD pipelines
├── config/              # JSON configuration
├── iac/                 # Terraform configuration
├── modules/             # Reusable Terraform modules
├── scripts/             # Validation and automation scripts
└── README.md           # This file
```

## Configuration

### 1. Update `config/github-resources.json`

```json
{
  "teams": ["SG-DevOps", "SG-Platform"],
  "repositories": [
    {
      "name": "my-app",
      "description": "Application repository",
      "team_permissions": [
        {"team": "SG-DevOps", "permission": "admin"},
        {"team": "SG-Platform", "permission": "write"}
      ]
    }
  ]
}
```

### 2. Configure GitHub Secrets

`AZURE_CLIENT_ID`: Service principal client ID
`AZURE_TENANT_ID`: Azure AD tenant ID
`AZURE_SUBSCRIPTION_ID`: Azure subscription ID
`GITHUB_APP_ID`: GitHub App ID
`GITHUB_APP_INSTALLATION_ID`: GitHub App installation ID
`GITHUB_APP_PRIVATE_KEY`: GitHub App private key (base64 encoded)

### 3. Update iac/terraform.tfvars
```
github_organization = "your-org-name"
github_app_id = "123456"
github_app_installation_id = "12345678"
```

Usage
Making Changes

Edit `config/github-resources.json`
Create PR with your changes
Review the Terraform plan posted as PR comment
Merge to apply changes

Local Development
# Initialize Terraform
cd iac
terraform init

# Preview changes
terraform plan

# Apply changes (not recommended locally)
terraform apply

Workflows
Pull Request Workflow

Validates JSON structure
Checks EntraID groups are synced
Runs `terraform plan`
Posts plan as PR comment

Apply Workflow

Triggered on merge to main
Applies Terraform changes
Updates GitHub resources
Posts summary to workflow

Important Notes

EntraID Groups: Must be created and assigned to GitHub EMU app before referencing
SCIM Sync: Takes 5-15 minutes after group assignment
Permissions: Derived from team names (no longer using R/M/A prefixes)
Everyone Team: Automatically gets read access to all repositories

Troubleshooting
EntraID Group Not Found

Verify group exists in Azure AD
Check group is assigned to GitHub EMU app
Wait for SCIM sync (5-15 minutes)
Run `scripts/validate-entraid-groups.ps1`

Terraform State Lock
# Break lock if stuck
az storage blob lease break \
  --blob-name github-emu.tfstate \
  --container-name tfstate \
  --account-name stgithubterraform

Permission Denied

Verify service principal has required permissions
Check OIDC federation is configured
Ensure GitHub App has correct permissions
