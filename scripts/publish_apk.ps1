<#
Script d'aide pour publier une APK sur la landing page `tmp-payrent-releases`.
Usage:
 .\scripts\publish_apk.ps1 -Version "1.0.2" -ApkPath "..\build\app\outputs\flutter-apk\app-release.apk" -RepoOwner "Espoir-oussa" -RepoName "payrent-releases" -Commit

- Le script met à jour `tmp-payrent-releases/version.json` avec la version, la taille et la date.
- Il ne téléverse pas l'APK sur GitHub ; il suppose que l'APK a été uploadé manuellement dans une Release, ou que tu fourniras l'URL via -ApkUrl.
- Si tu précises -Commit, le script fera un `git add/commit/push` sur la branche courante.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,

    [string]$ApkPath = "",

    [string]$ApkUrl = "",

    [string]$ReleasePage = "",

    [string]$RepoOwner = "Espoir-oussa",
    [string]$RepoName = "payrent-releases",

    [switch]$Commit
)

function Write-JsonFile($path, $obj) {
    $json = $obj | ConvertTo-Json -Depth 5
    $json | Out-File -FilePath $path -Encoding UTF8
}

$basePath = (Resolve-Path .).Path
$versionFile = Join-Path $basePath "tmp-payrent-releases\version.json"

$size = ""
if ($ApkPath -and (Test-Path $ApkPath)) {
    $bytes = (Get-Item $ApkPath).Length
    $size = [math]::Round($bytes / 1MB, 1).ToString() + " MB"
    if (-not $ApkUrl -or $ApkUrl -eq "") {
        $fileName = [System.IO.Path]::GetFileName($ApkPath)
        Write-Host "Aucun ApkUrl fourni ; vous devrez uploader l'APK sur une Release et fournir l'URL manuellement" -ForegroundColor Yellow
        Write-Host "Fichier local: $fileName, taille: $size" -ForegroundColor Green
    }
}

if (-not $ApkUrl -or $ApkUrl -eq "") {
    Write-Host "Aucun --ApkUrl fourni. Le champ apkUrl dans version.json restera vide." -ForegroundColor Yellow
}

$releaseDate = (Get-Date).ToString('yyyy-MM-dd')

$newObj = [ordered]@{
    version = $Version
    apkUrl = $ApkUrl
    releasePage = $ReleasePage
    size = $size
    releaseDate = $releaseDate
    changelog = @("Publication $Version")
}

Write-Host "Mise à jour de $versionFile" -ForegroundColor Cyan
Write-JsonFile -path $versionFile -obj $newObj

if ($Commit) {
    git add $versionFile
    git commit -m "chore: update tmp-payrent-releases version.json -> v$Version"
    git push
    Write-Host "Version poussée sur le remote." -ForegroundColor Green
} else {
    Write-Host "Fichier mis à jour localement. Utilise --Commit pour committer/pusher automatiquement." -ForegroundColor Green
}
