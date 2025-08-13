#!/usr/bin/env pwsh

<#
.SYNOPSIS
Validates that EntraID groups referenced in config exist in GitHub
#>

param(
    [string]$ConfigPath = "$PSScriptRoot/../config/github-resources.json",
    [string]$GitHubToken = $env:GITHUB_TOKEN
)

# Read configuration
$config = Get-Content $ConfigPath | ConvertFrom-Json

Write-Host "Validating EntraID groups are synced to GitHub..." -ForegroundColor Cyan

# Get external groups from GitHub
$headers = @{
    "Authorization" = "Bearer $GitHubToken"
    "Accept" = "application/vnd.github.v3+json"
}

try {
    $response = Invoke-RestMethod `
        -Uri "https://api.github.com/orgs/$($env:GITHUB_ORGANIZATION)/external-groups" `
        -Headers $headers `
        -Method Get
    
    $externalGroups = @{}
    foreach ($group in $response.groups) {
        $externalGroups[$group.name] = $group
    }
    
    # Check each team
    $missingGroups = @()
    foreach ($teamName in $config.teams) {
        if (-not $externalGroups.ContainsKey($teamName)) {
            $missingGroups += $teamName
        } else {
            Write-Host "✓ Found: $teamName" -ForegroundColor Green
        }
    }
    
    if ($missingGroups.Count -gt 0) {
        Write-Host "`n❌ Missing EntraID groups:" -ForegroundColor Red
        $missingGroups | ForEach-Object { Write-Host "   - $_" -ForegroundColor Red }
        Write-Host "`nEnsure these groups are:" -ForegroundColor Yellow
        Write-Host "1. Created in EntraID" -ForegroundColor Yellow
        Write-Host "2. Assigned to the GitHub EMU app" -ForegroundColor Yellow
        Write-Host "3. SCIM sync has completed (5-15 minutes)" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "`n✅ All EntraID groups are synced" -ForegroundColor Green
    
} catch {
    Write-Host "❌ Failed to query GitHub external groups: $_" -ForegroundColor Red
    exit 1
}