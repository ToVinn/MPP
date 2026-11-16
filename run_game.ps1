# Echoes of Astra - Portable Game Launcher (PowerShell)
# Bekerja di komputer / laptop user mana saja tanpa hardcoded path

$projectDir = $PSScriptRoot

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "        ECHOES OF ASTRA - 2D ANIME FANTASY RPG          " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

$godotExe = $null

# 1. Cek di PATH
$pathGodot = Get-Command "godot" -ErrorAction SilentlyContinue
if ($pathGodot) {
    $godotExe = $pathGodot.Source
}

# 2. Cek di folder proyek atau parent folder
if (-not $godotExe) {
    $candidates = Get-ChildItem -Path @($projectDir, "$projectDir\..", "$env:USERPROFILE\Downloads") -Filter "Godot*.exe" -Recurse -Depth 2 -ErrorAction SilentlyContinue
    if ($candidates) {
        $godotExe = $candidates[0].FullName
    }
}

# 3. Minta input jika belum ketemu
while (-not $godotExe -or -not (Test-Path $godotExe)) {
    Write-Host "[INFO] Godot Engine 4 executable tidak ditemukan otomatis." -ForegroundColor Yellow
    Write-Host "Silakan masukkan atau drag & drop path file Godot.exe Anda:"
    $inputPath = Read-Host "> "
    $inputPath = $inputPath.Trim('"', "'")
    if (Test-Path $inputPath) {
        $godotExe = $inputPath
    } else {
        Write-Host "[ERROR] Path tidak valid: $inputPath`n" -ForegroundColor Red
    }
}

Write-Host "[SUCCESS] Menjalankan dengan: $godotExe" -ForegroundColor Green
Write-Host "Direktori Proyek: $projectDir`n" -ForegroundColor Gray

Start-Process -FilePath $godotExe -ArgumentList @("--path", $projectDir)
