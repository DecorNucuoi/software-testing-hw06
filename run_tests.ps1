# run_tests.ps1 — Chạy test SẠCH tự động (kill node -> reset DB -> start server -> verify -> newman)
# Dùng: mở PowerShell, gõ:  cd D:\HW06 ; .\run_tests.ps1
# Nếu bị chặn script: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

$ErrorActionPreference = "Stop"
$SUT = "D:\eshop-sut_1\eshop-sut\backend"
$HW  = "D:\HW06"
$BASE = "http://localhost:3000"

Write-Host "== 1. Tat tat ca node.exe ==" -ForegroundColor Cyan
Get-Process node -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

Write-Host "== 2. Reset DB sach ==" -ForegroundColor Cyan
Set-Location $SUT
Remove-Item database.sqlite -ErrorAction SilentlyContinue
node database.js
Write-Host "   OK - da seed DB"

Write-Host "== 3. Khoi dong server (nen) ==" -ForegroundColor Cyan
$srv = Start-Process node -ArgumentList "server.js" -PassThru -WindowStyle Hidden
Start-Sleep 4

Write-Host "== 4. Verify server + DB ==" -ForegroundColor Cyan
try {
  $n = (Invoke-RestMethod "$BASE/api/products").Count
} catch {
  Write-Host "   !! Server chua len, doi them 3s..." -ForegroundColor Yellow
  Start-Sleep 3
  $n = (Invoke-RestMethod "$BASE/api/products").Count
}
Write-Host "   So san pham = $n (phai la 5)"
if ($n -ne 5) {
  Write-Host "   !! DB khong dung 5 san pham. Dung lai." -ForegroundColor Red
  Stop-Process -Id $srv.Id -Force 2>$null
  exit 1
}

Write-Host "== 5. Chay Newman (KHONG reset giua cac collection - da unique code) ==" -ForegroundColor Cyan
Set-Location $HW
if (-not (Test-Path newman)) { New-Item -ItemType Directory newman | Out-Null }

$env_file = "postman\EShop_HW06.postman_environment.json"
$cols = @(
  @{ name="API1"; file="postman\EShop_API1.postman_collection.json"; out="newman\newman-report-api1.html" },
  @{ name="API2"; file="postman\EShop_API2.postman_collection.json"; out="newman\newman-report-api2.html" }
)
$cols += @{ name="API3"; file="postman\EShop_API3.postman_collection.json"; out="newman\newman-report-api3.html" }

foreach ($c in $cols) {
  if (Test-Path $c.file) {
    Write-Host "`n--- $($c.name) ---" -ForegroundColor Green
    newman run $c.file -e $env_file -r "cli,htmlextra" --reporter-htmlextra-export $c.out
  } else {
    Write-Host "   (bo qua $($c.name): chua co $($c.file))" -ForegroundColor DarkGray
  }
}

Write-Host "`n== 6. Tat server ==" -ForegroundColor Cyan
Stop-Process -Id $srv.Id -Force 2>$null
Write-Host "XONG. Report HTML nam trong D:\HW06\newman\" -ForegroundColor Green
