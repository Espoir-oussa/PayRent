<#
PowerShell script to add attributes to Appwrite `invitations` collection.
Usage example:
  .\add_appwrite_invitations_fields.ps1 -Endpoint "https://fra.cloud.appwrite.io" -ProjectId "69393f23001c2e93607c" -DatabaseId "payrent_db" -CollectionId "invitations" -ApiKey "SCOPED_ADMIN_KEY"

This script calls Appwrite REST API to create 3 attributes on the collection:
- connectionCodeHash (string, size 256)
- connectionCodeExpiry (datetime)
- connectionCodeUsed (boolean, default false)

Be careful: you must have a valid admin API key (X-Appwrite-Key) that has permissions to modify the DB schema.
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

function Invoke-AppwriteApi($method, $url, $body) {
    $headers = @{
        'X-Appwrite-Project' = $ProjectId
        'X-Appwrite-Key' = $ApiKey
        'Content-Type' = 'application/json'
    }

    try {
        if ($body -ne $null) {
            $response = Invoke-RestMethod -Method $method -Uri $url -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
        } else {
            $response = Invoke-RestMethod -Method $method -Uri $url -Headers $headers
        }
        return $response
    } catch {
        Write-Error "Request failed: $_"
        return $null
    }
}

# Endpoint base
$base = "$Endpoint/v1/databases/$DatabaseId/collections/$CollectionId/attributes"

# 1) add string attribute for hash
Write-Host "Adding attribute: connectionCodeHash (string)"
$body = @{ key = 'connectionCodeHash'; size = 256; required = $false; array = $false }
Invoke-AppwriteApi -method 'POST' -url "$base/string" -body $body | Out-Null

# 2) add datetime attribute for expiry
Write-Host "Adding attribute: connectionCodeExpiry (datetime)"
$body = @{ key = 'connectionCodeExpiry'; required = $false; array = $false }
Invoke-AppwriteApi -method 'POST' -url "$base/datetime" -body $body | Out-Null

# 3) add boolean attribute for used flag
Write-Host "Adding attribute: connectionCodeUsed (boolean)"
$body = @{ key = 'connectionCodeUsed'; required = $false; default = $false; array = $false }
Invoke-AppwriteApi -method 'POST' -url "$base/boolean" -body $body | Out-Null

Write-Host "Done. Please verify the attributes exist in the Appwrite console."
