#!/usr/bin/env pwsh

<#
.SYNOPSIS
Ensures EntraID groups are assigned to GitHub EMU app using Graph API
#>

param(
    [string[]]$GroupNames,
    [string]$TenantId,
    [string]$ClientId = $env:AZURE_CLIENT_ID,
    [string]$GitHubEmuAppName = "GitHub Enterprise Managed User"
)

# Authenticate to Microsoft Graph
Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Cyan
Connect-MgGraph -TenantId $TenantId -ClientId $ClientId -NoWelcome

try {
    # Find GitHub EMU service principal
    $servicePrincipal = Get-MgServicePrincipal -Filter "displayName eq '$GitHubEmuAppName'"
    if (-not $servicePrincipal) {
        throw "GitHub EMU app not found in tenant"
    }
    
    $appId = $servicePrincipal.Id
    Write-Host "Found GitHub EMU app: $appId" -ForegroundColor Green
    
    foreach ($groupName in $GroupNames) {
        Write-Host "`nProcessing group: $groupName" -ForegroundColor Cyan
        
        # Find the group
        $group = Get-MgGroup -Filter "displayName eq '$groupName'"
        if (-not $group) {
            Write-Host "   ⚠️  Group not found in EntraID" -ForegroundColor Yellow
            continue
        }
        
        # Check if already assigned
        $assignment = Get-MgGroupAppRoleAssignment -GroupId $group.Id | 
            Where-Object { $_.ResourceId -eq $appId }
        
        if ($assignment) {
            Write-Host "   ✓ Already assigned" -ForegroundColor Green
        } else {
            # Assign the group to the app
            Write-Host "   → Assigning to GitHub EMU app..." -ForegroundColor Yellow
            
            # Get the default app role
            $appRole = $servicePrincipal.AppRoles | Where-Object { $_.Value -eq "User" }
            
            New-MgGroupAppRoleAssignment `
                -GroupId $group.Id `
                -PrincipalId $group.Id `
                -ResourceId $appId `
                -AppRoleId $appRole.Id
            
            Write-Host "   ✓ Assignment complete" -ForegroundColor Green
        }
    }
    
    Write-Host "`n⏳ Waiting for SCIM sync (this may take 5-15 minutes)..." -ForegroundColor Yellow
    Write-Host "Run the validate-entraid-groups.ps1 script to check sync status" -ForegroundColor Yellow
    
} finally {
    Disconnect-MgGraph
}