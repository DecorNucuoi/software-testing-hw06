# init_hw06.ps1 — dựng khung thư mục + git repo cho HW06
# Chạy: mở PowerShell, gõ:   cd D:\HW06 ; .\00_plan\init_hw06.ps1
# Nếu bị chặn script: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Stop"
$root = "D:\HW06"
Set-Location $root

Write-Host "== 1. Tao khung thu muc ==" -ForegroundColor Cyan
$dirs = @(
  "report", "postman", "postman\data", "newman", "testcases",
  "ai", "ai\prompts", "generator", "cicd", "cicd\screenshots",
  "bugs", "bugs\screenshots", "evidence", "openapi", ".github\workflows"
)
foreach ($d in $dirs) {
  if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
  # giu thu muc rong trong git
  $keep = Join-Path $d ".gitkeep"
  if (-not (Test-Path $keep)) { New-Item -ItemType File -Path $keep -Force | Out-Null }
}
Write-Host "   OK - da tao $($dirs.Count) thu muc"

Write-Host "== 2. Kiem tra moi truong ==" -ForegroundColor Cyan
node -v
git --version
try { newman -v } catch { Write-Host "   !! Chua cai Newman: npm install -g newman newman-reporter-htmlextra" -ForegroundColor Yellow }

Write-Host "== 3. Kiem tra backend EShop ==" -ForegroundColor Cyan
try {
  $r = Invoke-RestMethod -Uri "http://localhost:3000/api/products" -TimeoutSec 5
  Write-Host "   OK - backend dang chay, $($r.Count) san pham"
} catch {
  Write-Host "   !! Backend CHUA chay. Mo cua so khac va chay:" -ForegroundColor Yellow
  Write-Host "      cd D:\eshop-sut_1\eshop-sut\backend ; node server.js" -ForegroundColor Yellow
}

Write-Host "== 4. Khoi tao git ==" -ForegroundColor Cyan
if (-not (Test-Path ".git")) {
  git init | Out-Null
  git branch -M main
  Write-Host "   OK - da git init"
} else {
  Write-Host "   Da co .git, bo qua"
}

$remote = git remote 2>$null
if (-not ($remote -contains "origin")) {
  git remote add origin "https://github.com/DecorNucuoi/software-testing-hw06.git"
  Write-Host "   OK - da them remote origin"
} else {
  Write-Host "   Remote origin da ton tai:"
  git remote -v
}

Write-Host "== 5. Commit dau tien ==" -ForegroundColor Cyan
git add -A
git commit -m "chore: khoi tao cau truc HW06 - API testing EShop" 2>$null
Write-Host ""
Write-Host "XONG. Buoc tiep theo:" -ForegroundColor Green
Write-Host "  1) Tao repo PUBLIC ten 'software-testing-hw06' tren GitHub (bat tab Issues)"
Write-Host "  2) git push -u origin main"
Write-Host "  3) Import postman\EShop_HW06.postman_environment.json vao Postman"
