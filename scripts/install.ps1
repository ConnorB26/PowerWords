# ===== CONFIG =====
$AddonName = "PowerWords"
$RepoRoot  = Split-Path -Parent $PSScriptRoot
$Source    = Join-Path $RepoRoot $AddonName

# Change this if your WoW install is non-standard
$WowAddons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"

$Destination = Join-Path $WowAddons $AddonName
# ==================

Write-Host "Installing $AddonName..." -ForegroundColor Cyan

if (!(Test-Path $Source)) {
    Write-Error "Source folder not found: $Source"
    exit 1
}

if (!(Test-Path $WowAddons)) {
    Write-Error "WoW AddOns folder not found: $WowAddons"
    exit 1
}

# Remove existing addon (clean install)
if (Test-Path $Destination) {
    Remove-Item $Destination -Recurse -Force
}

# Copy addon
Copy-Item $Source $Destination -Recurse -Force

Write-Host "Installed to $Destination" -ForegroundColor Green
Write-Host "Type /reload in-game to apply changes." -ForegroundColor Yellow