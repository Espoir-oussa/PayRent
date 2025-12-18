Param(
  [string]$AppwriteEndpoint = $(throw 'APPWRITE_ENDPOINT is required'),
  [string]$ProjectId = $(throw 'APPWRITE_PROJECT is required'),
  [string]$ApiKey = $(throw 'APPWRITE_API_KEY is required'),
  [string]$FunctionName = 'create-contract',
  [string]$Runtime = 'node-18.0',
  [string]$EntryPoint = 'index.js',
  [string]$SourceDir = 'functions/create-contract',
  [string]$FunctionId = ''
)

# Zip sources
$zip = "$FunctionName.zip"
if (Test-Path $zip) { Remove-Item $zip }
Write-Host "📦 Zipping $SourceDir -> $zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($SourceDir, $zip)

if ([string]::IsNullOrEmpty($FunctionId)) {
  Write-Host "🔎 No FUNCTION_ID provided. Creating function '$FunctionName'..."
  $body = @{ name = $FunctionName; runtime = $Runtime; entrypoint = $EntryPoint } | ConvertTo-Json
  $resp = Invoke-RestMethod -Method Post -Uri "$AppwriteEndpoint/functions" -Headers @{ 'x-appwrite-project' = $ProjectId; 'x-appwrite-key' = $ApiKey; 'content-type' = 'application/json' } -Body $body
  $FunctionId = $resp.'$id'
  if (-not $FunctionId) { Write-Error "Could not create function: $resp"; exit 1 }
  Write-Host "✅ Function created: $FunctionId"
} else {
  Write-Host "ℹ️ Using FUNCTION_ID: $FunctionId"
}

# Upload deployment
Write-Host "🚀 Creating deployment for function $FunctionId"
$uri = "$AppwriteEndpoint/functions/$FunctionId/deployments"
$form = @{ code = Get-Item $zip }
$deployResp = Invoke-RestMethod -Method Post -Uri $uri -Headers @{ 'x-appwrite-project' = $ProjectId; 'x-appwrite-key' = $ApiKey } -Form $form
Write-Host "Deployment response: $deployResp"
if (-not $deployResp.'$id') { Write-Error "Deployment failed"; exit 1 }
Write-Host "✅ Deployment created: $($deployResp.'$id')"
Write-Host "🔁 Note: Copiez l'ID de la function ($FunctionId) et mettez à jour 'Environment.createContractFunctionId' dans 'lib/config/environment.dart'"
Write-Host "🎉 Done."