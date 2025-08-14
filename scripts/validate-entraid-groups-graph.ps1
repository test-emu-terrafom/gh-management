#!/usr/bin/env pwsh

param(
    [string]$ConfigPath = "$PSScriptRoot/../config/github-resources.json"
)

# Use Azure CLI to get token for Graph API
$token = az account get-access-token --resource https://graph.microsoft.com --query accessToken -o tsv

if (!$token) {
    Write-Error "Failed to get Graph API token. Ensure you're logged in with 'az login'"
    exit 1
}

# Read configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "Validating EntraID groups via Microsoft Graph API..." -ForegroundColor Cyan

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$missingGroups = @()
$foundGroups = @()

foreach ($groupName in $config.teams) {
    Write-Host "Checking group: $groupName" -ForegroundColor Yellow
    
    # Query Graph API for the group
    $uri = "https://graph.microsoft.com/v1.0/groups?`$filter=displayName eq '$groupName'&`$select=id,displayName,members"
    
    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        
        if ($response.value.Count -gt 0) {
            $group = $response.value[0]
            Write-Host "✓ Found: $groupName (ID: $($group.id))" -ForegroundColor Green
            
            # Get member count
            $membersUri = "https://graph.microsoft.com/v1.0/groups/$($group.id)/members/`$count"
            $memberCount = Invoke-RestMethod -Uri $membersUri -Headers $headers -Method Get
            Write-Host "  Members: $memberCount" -ForegroundColor Gray
            
            $foundGroups += @{
                Name = $groupName
                Id = $group.id
                MemberCount = $memberCount
            }
        } else {
            Write-Host "✗ Not found: $groupName" -ForegroundColor Red
            $missingGroups += $groupName
        }
    } catch {
        Write-Host "✗ Error checking $groupName : $_" -ForegroundColor Red
        $missingGroups += $groupName
    }
}

if ($missingGroups.Count -gt 0) {
    Write-Host "`n❌ Missing groups in EntraID:" -ForegroundColor Red
    $missingGroups | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "`n✅ All groups exist in EntraID with members" -ForegroundColor Green
Write-Host "`n📝 In production, these would sync to GitHub via SCIM as external groups" -ForegroundColor Yellow

# Output found groups for next steps
$foundGroups | ConvertTo-Json | Out-File "$PSScriptRoot/../entraid-groups.json"