# HW06 — HƯỚNG DẪN CÀI ĐẶT & VERIFY MÔI TRƯỜNG

> Làm hết mục này **trước** khi chạy prompt đầu tiên. Mỗi bước có lệnh verify — chạy xong phải thấy đúng output mới đi tiếp.
> Bạn đã có: Node.js 18+, npm, Git + GitHub. Chưa có: **Postman Desktop**, **Newman**.

---

## Bước 0 — Kiểm tra cái đã có

Mở **PowerShell** (không cần admin):

```powershell
node -v      # phải >= v18
npm -v
git --version
```

Nếu `node -v` < 18 → tải LTS tại https://nodejs.org rồi mở lại PowerShell.

---

## Bước 1 — Cài Postman Desktop

Tải: https://www.postman.com/downloads/ → bản **Windows 64-bit** → cài → đăng nhập bằng Google/email.

> Phải đăng nhập thì mới có **Workspace**, **Monitor**, **Mock Server** — 3 tính năng đề yêu cầu "dùng càng nhiều càng tốt".

**Verify:** mở Postman → góc trái thấy tên workspace → `New` → thấy đủ mục *Collection / Environment / Mock Server / Monitor*.

---

## Bước 2 — Cài Newman + reporter HTML

```powershell
npm install -g newman newman-reporter-htmlextra
```

**Verify:**

```powershell
newman -v          # ví dụ 6.x.x
newman run --help  # không lỗi
```

> Nếu PowerShell báo *"cannot be loaded because running scripts is disabled"*:
> ```powershell
> Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
> ```

---

## Bước 3 — Khởi động backend EShop

```powershell
cd D:\eshop-sut_1\eshop-sut\backend
npm install
node database.js     # chỉ chạy 1 lần — tạo + seed database.sqlite
node server.js       # GIỮ CỬA SỔ NÀY MỞ suốt buổi test
```

Terminal phải in ra dòng server chạy ở `http://localhost:3000`.

**Verify bằng cửa sổ PowerShell THỨ HAI:**

```powershell
curl.exe http://localhost:3000/api/products
curl.exe http://localhost:3000/api/products/1
```

Phải trả về JSON sản phẩm. Nếu rỗng → chạy lại `node database.js`.

### Reset DB khi cần (rất hay dùng)

Test FR-15 sẽ tạo/xóa sản phẩm lung tung. Khi muốn về trạng thái sạch:

```powershell
# Ctrl+C tắt server trước
cd D:\eshop-sut_1\eshop-sut\backend
del database.sqlite
node database.js
node server.js
```

> 💡 Backup 1 bản sạch để restore nhanh:
> ```powershell
> copy database.sqlite database.clean.sqlite
> ```

---

## Bước 4 — Tài khoản seed (dùng cho test auth)

| Vai trò | Email | Mật khẩu |
|---------|-------|----------|
| Admin | `admin@eshop.com` | `Admin123!` |
| User thường | `test@eshop.com` | `Test1234!` |

⚠️ File `setup_guide.md` trong repo ghi mật khẩu admin là `admin123` — **SAI**. Giá trị đúng nằm trong `backend/database.js`. Đây cũng là *finding* đáng ghi vào bug report (spec không khớp implementation).

**Verify lấy token:**

```powershell
curl.exe -X POST http://localhost:3000/api/login -H "Content-Type: application/json" -d "{\"email\":\"admin@eshop.com\",\"password\":\"Admin123!\"}"
```

Phải trả về `token` (chuỗi JWT). Copy tạm để test.

---

## Bước 5 — Dựng repo bài nộp

```powershell
cd D:\HW06
git init
git branch -M main

# tạo khung thư mục
mkdir report, postman, postman\data, newman, testcases, ai, ai\prompts, generator, cicd, cicd\screenshots, bugs, bugs\screenshots, evidence, openapi
mkdir .github\workflows
```

Tạo file `D:\HW06\.gitignore`:

```
node_modules/
*.sqlite
.DS_Store
Thumbs.db
```

Tạo repo **public** trên GitHub tên `software-testing-hw06`, rồi:

```powershell
git remote add origin https://github.com/DecorNucuoi/software-testing-hw06.git
git add .
git commit -m "chore: init HW06 structure"
git push -u origin main
```

**Verify:** Vào tab **Issues** của repo → nếu tab bị ẩn thì bật ở `Settings → General → Features → Issues`. Đề bắt buộc phải có Issues.

---

## Bước 6 — Postman: workspace + environment + pre-request script

1. **Workspace**: `Workspaces → Create Workspace` → tên `HW06-EShop-API-Testing` → Personal.
2. **Environment**: `Environments → +` → tên `EShop-Local`, thêm biến:

   | Variable | Initial value | Type |
   |----------|---------------|------|
   | `baseUrl` | `http://localhost:3000` | default |
   | `studentId` | `23127362` | default |
   | `adminEmail` | `admin@eshop.com` | default |
   | `adminPassword` | `Admin123!` | secret |
   | `userEmail` | `test@eshop.com` | default |
   | `userPassword` | `Test1234!` | secret |
   | `adminToken` | *(để trống)* | secret |
   | `userToken` | *(để trống)* | secret |
   | `productId` | *(để trống)* | default |

3. **Collection**: `New → Collection` → tên `EShop-HW06`, tạo 3 folder: `API1-FR06-ProductDetail`, `API2-FR09-Coupon`, `API3-FR15-ProductCRUD`.

4. **Pre-request Script ở CẤP COLLECTION** (tab `Scripts → Pre-request` của collection, không phải của từng request):

```javascript
// Bắt buộc theo đề: mọi request đều mang X-Student-Id
const sid = pm.environment.get("studentId") || "UNSET";
pm.request.headers.upsert({ key: "X-Student-Id", value: sid });

// Bằng chứng cho anti-cheat: chụp Console thấy dòng này
console.log("[HW06] X-Student-Id =", sid, "->", pm.request.url.toString());
```

**Verify (đây chính là evidence anti-cheat):**
- Mở `View → Show Postman Console` (Ctrl+Alt+C)
- Gửi 1 request bất kỳ tới `{{baseUrl}}/api/products/1`
- Trong Console mở request → mục **Request Headers** phải thấy `X-Student-Id: 23127362`
- **Chụp màn hình** lưu vào `D:\HW06\evidence\postman_console_student_id.png`

---

## Bước 7 — Verify Newman end-to-end (làm ngay, đừng để cuối)

Export collection + environment ra file:
- Collection: `...` → `Export` → Collection v2.1 → lưu `D:\HW06\postman\EShop_HW06.postman_collection.json`
- Environment: `Environments` → `...` → `Export` → lưu `D:\HW06\postman\EShop_HW06.postman_environment.json`

Chạy:

```powershell
cd D:\HW06
newman run postman\EShop_HW06.postman_collection.json `
  -e postman\EShop_HW06.postman_environment.json `
  -r cli,htmlextra `
  --reporter-htmlextra-export newman\newman-report-full.html
```

**Verify:** đầu output Newman phải thấy URL `http://localhost:3000/...` (hostname `localhost` = đúng yêu cầu anti-cheat), và file HTML được sinh ra trong `newman\`.

⚠️ **Nhớ export lại collection mỗi lần sửa trong Postman** — Newman đọc file, không đọc app.

---

## Bước 8 — GitHub Actions (dựng sẵn, dùng ở G5)

Tạo `D:\HW06\.github\workflows\newman.yml`:

```yaml
name: API Tests (Newman)

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  api-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Checkout SUT
        uses: actions/checkout@v4
        with:
          repository: ttbhanh/eshop-sut
          path: sut

      - name: Start EShop backend
        run: |
          cd sut/backend
          npm install
          node database.js
          nohup node server.js &
          npx wait-on http://localhost:3000/api/products --timeout 60000

      - name: Install Newman
        run: npm install -g newman newman-reporter-htmlextra

      - name: Run API tests
        run: |
          newman run postman/EShop_HW06.postman_collection.json \
            -e postman/EShop_HW06.postman_environment.json \
            --env-var "baseUrl=http://localhost:3000" \
            --env-var "studentId=23127362" \
            -r cli,htmlextra \
            --reporter-htmlextra-export newman/ci-report.html

      - name: Upload report
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: newman-report
          path: newman/ci-report.html
```

> Cách tạo **commit fail đúng 1 test case** (yêu cầu của đề): sau khi có bản all-pass, sửa **1** assertion trong 1 request thành điều kiện sai (ví dụ `pm.response.to.have.status(999)`), commit riêng với message `test: intentional failing case for CI demo`, push → chụp run đỏ. Sau đó revert.

---

## ✅ Bảng verify cuối cùng

| # | Kiểm tra | OK? |
|---|----------|-----|
| 1 | `node -v` ≥ 18, `git --version` chạy được | ☐ |
| 2 | Postman Desktop đã đăng nhập, thấy Mock Server & Monitor | ☐ |
| 3 | `newman -v` chạy được | ☐ |
| 4 | `curl http://localhost:3000/api/products` trả JSON | ☐ |
| 5 | Login admin trả về `token` | ☐ |
| 6 | Repo GitHub public đã tạo, tab **Issues** đang bật | ☐ |
| 7 | Postman Console hiện `X-Student-Id` + đã chụp screenshot | ☐ |
| 8 | Newman chạy được và sinh file HTML | ☐ |
| 9 | Đã backup `database.clean.sqlite` | ☐ |
| 10 | Đã tạo đủ khung thư mục trong `D:\HW06` | ☐ |

Xong 10/10 → nhắn tôi, ta bắt đầu **P0** cho API 1.
