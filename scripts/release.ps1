# Script de release PayRent
# Usage: .\scripts\release.ps1 -Version "1.0.2"
# Ce script met a jour la version, build l'APK, et le publie sur GitHub

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$false)]
    [string]$Changelog = "Ameliorations et corrections de bugs"
)

$ErrorActionPreference = "Stop"

Write-Host "Release PayRent v$Version" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 0. Mise a jour de la version dans pubspec.yaml
Write-Host "`nMise a jour de pubspec.yaml..." -ForegroundColor Yellow
Set-Location "D:\Flutter\payrent"

$pubspecPath = "D:\Flutter\payrent\pubspec.yaml"
$pubspecContent = Get-Content $pubspecPath -Raw

# Extraire le build number actuel et l'incrementer
if ($pubspecContent -match 'version:\s*[\d.]+\+(\d+)') {
    $currentBuildNumber = [int]$matches[1]
    $newBuildNumber = $currentBuildNumber + 1
} else {
    $newBuildNumber = 1
}

# Remplacer la version
$pubspecContent = $pubspecContent -replace 'version:\s*[\d.]+\+\d+', "version: $Version+$newBuildNumber"
$pubspecContent | Set-Content $pubspecPath -NoNewline
Write-Host "pubspec.yaml mis a jour: $Version+$newBuildNumber" -ForegroundColor Green

# 1. Build APK
Write-Host "`nGeneration de l'APK..." -ForegroundColor Yellow
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erreur lors du build" -ForegroundColor Red
    exit 1
}

$apkPath = "D:\Flutter\payrent\build\app\outputs\flutter-apk\app-release.apk"
$apkSize = [math]::Round((Get-Item $apkPath).Length / 1MB, 1)

Write-Host "APK genere ($apkSize MB)" -ForegroundColor Green

# 2. Mise a jour version.json
Write-Host "`nMise a jour de version.json..." -ForegroundColor Yellow
$versionJson = @{
    version = $Version
    apkUrl = "https://github.com/Espoir-oussa/payrent-releases/releases/download/v$Version/app-release.apk"
    size = "$apkSize MB"
    releaseDate = (Get-Date -Format "yyyy-MM-dd")
    changelog = @(
        $Changelog
    )
    minAndroidVersion = "5.0"
} | ConvertTo-Json -Depth 3

$versionJson | Out-File -FilePath "D:\Flutter\payrent\web_redirect\version.json" -Encoding UTF8
Write-Host "version.json mis a jour" -ForegroundColor Green

# 3. Push web_redirect
Write-Host "`nPush vers GitHub Pages..." -ForegroundColor Yellow
Set-Location "D:\Flutter\payrent\web_redirect"
git add version.json
git commit -m "Release v$Version"
git push origin main
Write-Host "GitHub Pages mis a jour" -ForegroundColor Green

# 4. Creation de la release GitHub avec upload APK
Write-Host "`nCreation de la release GitHub..." -ForegroundColor Yellow

# Rafraichir le PATH pour s'assurer que gh est accessible
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Verifier si gh est installe
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue
if (-not $ghInstalled) {
    Write-Host "GitHub CLI (gh) n'est pas installe." -ForegroundColor Red
    Write-Host "Installez-le avec: winget install --id GitHub.cli" -ForegroundColor Yellow
    exit 1
}

# Creer la release et uploader l'APK
Set-Location "D:\Flutter\payrent\web_redirect"
$releaseNotes = "PayRent v$Version - APK Android: $apkSize MB - Date: $(Get-Date -Format 'dd/MM/yyyy')"

gh release create "v$Version" $apkPath --repo "Espoir-oussa/payrent-releases" --title "PayRent v$Version" --notes $releaseNotes

if ($LASTEXITCODE -eq 0) {
    Write-Host "Release v$Version creee avec succes !" -ForegroundColor Green
    Write-Host "APK uploade automatiquement !" -ForegroundColor Green
} else {
    Write-Host "Erreur lors de la creation de la release" -ForegroundColor Red
    exit 1
}

# 5. Resume final
Write-Host "`n" -ForegroundColor White
Write-Host "================================" -ForegroundColor Cyan
Write-Host "RELEASE TERMINEE !" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host "`nAPK genere: $apkSize MB" -ForegroundColor Green
Write-Host "version.json mis a jour" -ForegroundColor Green
Write-Host "GitHub Pages deploye" -ForegroundColor Green
Write-Host "Release GitHub creee avec APK" -ForegroundColor Green
Write-Host "`nLien de telechargement:" -ForegroundColor Cyan
Write-Host "https://github.com/Espoir-oussa/payrent-releases/releases/download/v$Version/app-release.apk" -ForegroundColor White
Write-Host "`nPage de telechargement:" -ForegroundColor Cyan
Write-Host "https://espoir-oussa.github.io/payrent-releases" -ForegroundColor White
Write-Host "`n"

# Ouvrir la page de release
Start-Process "https://github.com/Espoir-oussa/payrent-releases/releases/tag/v$Version"
