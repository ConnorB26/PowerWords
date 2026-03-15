# ===== CONFIG =====
$AddonName = "PowerWords"
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Change this if your WoW install is non-standard
$WowAddons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"

$Destination = Join-Path $WowAddons $AddonName
# ==================

Write-Host "Installing $AddonName..." -ForegroundColor Cyan

if (!(Test-Path $WowAddons)) {
    Write-Error "WoW AddOns folder not found: $WowAddons"
    exit 1
}

# Remove existing addon (clean install)
if (Test-Path $Destination) {
    Remove-Item $Destination -Recurse -Force
}

New-Item $Destination -ItemType Directory | Out-Null

# Copy only addon files from repo root
Get-ChildItem $RepoRoot -File | Where-Object { $_.Extension -in ".lua", ".toc" } |
ForEach-Object { Copy-Item $_.FullName $Destination -Force }

Write-Host "Installed to $Destination" -ForegroundColor Green
Write-Host "Type /reload in-game to apply changes." -ForegroundColor Yellow
