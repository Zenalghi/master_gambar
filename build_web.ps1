# ================================================================
# BUILD SCRIPT - Flutter Web App
# ================================================================
# Cara pakai:
#   .\build_web.ps1
# ================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  R-Desk Web - Flutter Web Build Script" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# ── 1. Flutter build web ─────────────────────────────────────────
Write-Host "[1/3] Menjalankan 'flutter build web'..." -ForegroundColor Yellow
Set-Location $ScriptDir
flutter build web --release
if ($LASTEXITCODE -ne 0) { Write-Error "flutter build web gagal!"; exit 1 }
Write-Host "     Build selesai." -ForegroundColor Green

# ── 2. Copy ke folder tujuan ─────────────────────────────────────
$BuildOutput = Join-Path $ScriptDir "build\web"
$DestFolder  = "C:\Flutter\Web\R-Desk-web"

Write-Host ""
Write-Host "[2/3] Menyalin hasil build..." -ForegroundColor Yellow
Write-Host "      Dari : $BuildOutput"
Write-Host "      Ke   : $DestFolder"

# Buat parent folder jika belum ada
$DestParent = Split-Path -Parent $DestFolder
if (-not (Test-Path $DestParent)) {
    New-Item -ItemType Directory -Path $DestParent -Force | Out-Null
}

# Hapus isi lama, pertahankan folder root (agar Docker files tidak terhapus)
if (Test-Path $DestFolder) {
    Write-Host "      (Menghapus isi folder web lama...)" -ForegroundColor DarkGray
    # Hapus hanya konten Flutter web (bukan Dockerfile/nginx.conf/dll)
    $WebItems = @("index.html", "main.dart.js", "flutter.js", "flutter_bootstrap.js",
                  "assets", "canvaskit", "icons", "manifest.json", "favicon.png",
                  "flutter_service_worker.js", "version.json")
    foreach ($item in $WebItems) {
        $target = Join-Path $DestFolder $item
        if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    }
} else {
    New-Item -ItemType Directory -Path $DestFolder -Force | Out-Null
}

# Copy hasil build web
Copy-Item -Recurse -Force "$BuildOutput\*" $DestFolder
Write-Host "     Salin selesai." -ForegroundColor Green

Write-Host ""
Write-Host "[3/3] Selesai!" -ForegroundColor Green
Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host "  SELESAI!  Output: $DestFolder" -ForegroundColor Cyan
Write-Host "  Jalankan Docker: cd $DestFolder && docker compose up -d" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""
