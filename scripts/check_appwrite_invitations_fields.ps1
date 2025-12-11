<#
PowerShell script to check that the `invitations` collection has the required attributes.
Usage:
  .\scripts\check_appwrite_invitations_fields.ps1 -Endpoint "https://fra.cloud.appwrite.io" -ProjectId "69393f23001c2e93607c" -DatabaseId "payrent_db" -CollectionId "invitations" -ApiKey "SCOPED_ADMIN_KEY"

This script calls Appwrite API to GET the collection metadata and lists attributes, then verifies the presence
of connectionCodeHash, connectionCodeExpiry, connectionCodeUsed.
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$Endpoint,
    [Parameter(Mandatory=$true)]
    [string]$ProjectId,
    [Parameter(Mandatory=$true)]
    [string]$DatabaseId,
    [Parameter(Mandatory=$true)]
    [string]$CollectionId,
    [Parameter(Mandatory=$true)]
    [string]$ApiKey
)

$headers = @{ 'X-Appwrite-Project' = $ProjectId; 'X-Appwrite-Key' = $ApiKey }
$url = "$Endpoint/v1/databases/$DatabaseId/collections/$CollectionId"

try {
    $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
} catch {
    Write-Host "❌ Request failed: $_" -ForegroundColor Red
    exit 2
}

# The collection object contains an attributes array
if (-not $resp.attributes) {
    Write-Host "❌ La collection ne contient pas d'attributs ou la réponse est inattendue." -ForegroundColor Red
    Write-Host (ConvertTo-Json $resp -Depth 4)
    exit 3
}

$keys = $resp.attributes | ForEach-Object { $_.key }
Write-Host "Attributs trouvés dans la collection $CollectionId :" -ForegroundColor Cyan
$keys | ForEach-Object { Write-Host " - $_" }

$required = @('connectionCodeHash','connectionCodeExpiry','connectionCodeUsed')
$missing = @()
foreach ($r in $required) {
    if (-not ($keys -contains $r)) { $missing += $r }
}

if ($missing.Count -eq 0) {
    Write-Host "✅ Tous les attributs requis sont présents." -ForegroundColor Green
    exit 0
} else {
    Write-Host "⚠️ Attributs manquants : $($missing -join ', ')" -ForegroundColor Yellow
    exit 1
}