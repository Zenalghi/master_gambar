# ================================================================
# BUILD SCRIPT - Flutter Windows Desktop App
# ================================================================
# Cara pakai:
#   .\build_desktop.ps1
# ================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  R-Desk - Flutter Windows Build Script" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Baca versi dari pubspec.yaml ──────────────────────────────
$PubspecPath = Join-Path $ScriptDir "pubspec.yaml"
if (-not (Test-Path $PubspecPath)) {
    Write-Error "pubspec.yaml tidak ditemukan di: $PubspecPath"
    exit 1
}

$VersionLine = Get-Content $PubspecPath | Where-Object { $_ -match "^\s*version:" }
if (-not $VersionLine) {
    Write-Error "Baris 'version:' tidak ditemukan di pubspec.yaml"
    exit 1
}

# Ambil versi, buang build-number (+1) jika ada
$VersionFull = ($VersionLine -replace "^\s*version:\s*", "").Trim()
$Version     = ($VersionFull -split "\+")[0].Trim()
Write-Host "Versi terdeteksi dari pubspec.yaml: $VersionFull  ->  v$Version" -ForegroundColor Green

# ── 2. Flutter build windows ─────────────────────────────────────
Write-Host ""
Write-Host "[1/5] Menjalankan 'flutter build windows'..." -ForegroundColor Yellow
Set-Location $ScriptDir
flutter build windows --release
if ($LASTEXITCODE -ne 0) { Write-Error "flutter build windows gagal!"; exit 1 }
Write-Host "     Build selesai." -ForegroundColor Green

# ── 3. Tentukan folder tujuan ─────────────────────────────────────
$AppName     = "R-Desk-v$Version"
$DestRoot    = "C:\Flutter\Dekstop App"
$DestFolder  = Join-Path $DestRoot $AppName
$ZipPath     = Join-Path $DestRoot "$AppName.zip"
$BuildOutput = Join-Path $ScriptDir "build\windows\x64\runner\Release"

Write-Host ""
Write-Host "[2/5] Menyiapkan folder tujuan..." -ForegroundColor Yellow
Write-Host "      Dari : $BuildOutput"
Write-Host "      Ke   : $DestFolder"

# Buat parent folder jika belum ada
if (-not (Test-Path $DestRoot)) {
    New-Item -ItemType Directory -Path $DestRoot -Force | Out-Null
}

# Hapus folder lama jika ada agar bersih
if (Test-Path $DestFolder) {
    Write-Host "      (Menghapus folder lama: $DestFolder)" -ForegroundColor DarkGray
    Remove-Item -Recurse -Force $DestFolder
}

# Copy hasil build
Copy-Item -Recurse -Force $BuildOutput $DestFolder
Write-Host "     Copy selesai." -ForegroundColor Green

# ── 4. Buat config.json ──────────────────────────────────────────
Write-Host ""
Write-Host "[3/5] Membuat config.json..." -ForegroundColor Yellow
$ConfigPath = Join-Path $DestFolder "config.json"
$ConfigJson = '{
  "baseUrls": [
    "http://192.168.100.111/api",
    "http://100.116.54.6/api"
  ],
  "timeoutMs": 500
}'
Set-Content -Path $ConfigPath -Value $ConfigJson -Encoding UTF8
Write-Host "      Dibuat di: $ConfigPath" -ForegroundColor Green

# ── 5. Compress ke ZIP ───────────────────────────────────────────
Write-Host ""
Write-Host "[4/5] Mengompresi menjadi: $ZipPath" -ForegroundColor Yellow
if (Test-Path $ZipPath) {
    Remove-Item -Force $ZipPath
}
Compress-Archive -Path $DestFolder -DestinationPath $ZipPath -CompressionLevel Optimal
Write-Host "     Kompresi selesai: $ZipPath" -ForegroundColor Green

# ── 6. Buka folder di File Explorer ─────────────────────────────
Write-Host ""
Write-Host "[5/5] Membuka folder: $DestRoot" -ForegroundColor Yellow
Start-Process explorer.exe $DestRoot

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  SELESAI!  Output : $DestFolder" -ForegroundColor Cyan
Write-Host "  ZIP      : $ZipPath" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
