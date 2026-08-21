# HW06 — API Testing trên EShop SUT

**Sinh viên:** 23127362 · **Repo:** https://github.com/DecorNucuoi/software-testing-hw06
**SUT:** EShop (Node.js + Express + SQLite), chạy tại `http://localhost:3000`
**Runner:** Postman (thiết kế) + Newman (thực thi, xuất báo cáo htmlextra)
**Header bắt buộc mọi request (định danh bài nộp):** `X-Student-Id: 23127362` — tự chèn bằng pre-request script ở cấp collection.

Bài gồm **3 API**, mỗi API đi trọn pipeline: *Generate (AI) → Audit → Extend → Execute (Newman) → Bug report*; cộng **1 Agent Skill** tự sinh test.

---

## 1. Ba API được kiểm thử

| # | FR | Endpoint | Pool / Kỹ thuật trọng tâm |
|---|-----|----------|----------------------------|
| API 1 | FR-06 | `GET /api/products/:id` | EP + BVA, State Transition, Security, Schema |
| API 2 | FR-09 | `POST /api/apply-coupon` | Decision Table (17 rule) + Formula, State, Security |
| API 3 | FR-15 | `POST / PUT / DELETE /api/products` (+ `POST /api/admin/import-products`) | CRUD, phân quyền, robustness |

---

## 2. Cấu trúc repository (phần đẩy lên git)

```
software-testing-hw06/
├─ postman/       Collection Postman v2.1 (API1/API2/API3) + environment
├─ testcases/     Bảng test case + audit + extend + CSV
├─ newman/        Báo cáo Newman htmlextra (.html) — kết quả thực thi
├─ bugs/          bug_report.md (20 bug) + bugs/screenshots/
├─ openapi/       Đặc tả API (spec đầu vào cho việc sinh test)
├─ .github/       workflows/newman.yml — CI chạy Newman
├─ .gitignore
└─ README.md      (file này)
```

> **Nộp riêng qua LMS (không đẩy git theo yêu cầu):** báo cáo tổng (`report/`), báo cáo AI Audit & AI Critique (`ai/`), Agent Skill (`generator/`) và **diagram pipeline tự vẽ tay** (chống gian lận). `00_plan/` là ghi chú nội bộ, đã gitignore.

---

## 3. Bảng tự chấm điểm (Assessment Template — mục 15 của đề)

| No. | Criteria | Grade (max) | Self-Assessed Grade |
|-----|----------|-------------|---------------------|
| 1 | API 1 — full pipeline (generate + audit + extend + execute + bugs) | 30 | **30** |
| 2 | API 2 — full pipeline (same criteria) | 30 | **30** |
| 3 | API 3 — full pipeline (same criteria) | 30 | **30** |
| 4 | Agent Skill (AI-driven test generator) | 10 | **10** |
| | **Total** | **100** | **100** |

Căn cứ chi tiết từng hạng mục (điểm con trong ngoặc, cột "Chứng cứ" trỏ file kiểm chứng được):

### API 1 — FR-06 `GET /api/products/:id` → tự chấm **30/30**

| Hạng mục | Yêu cầu đề | Đã làm | Chứng cứ |
|----------|-----------|--------|----------|
| Generate (10) | ≥35 TC do AI sinh, không bịa | **64 TC** (Domain 25 · State 12 · Security 17 · Schema 10) | `testcases/testcases_api1_extended.md`, `postman/EShop_API1.postman_collection.json` |
| Audit (5) | Gắn nhãn VALID/INVALID/INCOMPLETE | 64 VALID · 0 INVALID · nêu điểm cần vá khi thực thi | `testcases/testcases_api1_extended.md` §Audit |
| Extend (5) | ≥5 TC AI bỏ sót + lý do | **6 TC** | `testcases/testcases_api1_extended.md` |
| Execute (5) | Chạy Newman, có evidence | 68 request · 181 assert · **146 pass / 35 fail** | `newman/newman-report-api1.html` |
| Bug (5) | Báo cáo bug thật | **8 bug** (2 Critical: SQLi `?search` lộ mật khẩu, plaintext password) | `bugs/bug_report.md` |

### API 2 — FR-09 `POST /api/apply-coupon` → tự chấm **30/30**

| Hạng mục | Yêu cầu | Đã làm | Chứng cứ |
|----------|---------|--------|----------|
| Generate (10) | ≥35 TC | **91 TC** (Domain 56 · State 9 · Security 19 · Schema 10) — có Decision Table 17 rule | `testcases/testcases_api2_extended.md` |
| Audit (5) | Gắn nhãn | 91 VALID · 0 INVALID · **3 BLOCKED** (nêu rõ lý do hạ tầng) | `testcases/testcases_api2_extended.md` §Audit |
| Extend (5) | ≥5 TC | **5 TC** | `testcases/testcases_api2_extended.md` |
| Execute (5) | Newman | 69 request · 168 assert · **139 pass / 29 fail** | `newman/newman-report-api2.html` |
| Bug (5) | Bug thật | **6 bug** (1 Critical: công thức percent ra tiền âm) | `bugs/bug_report.md` |

### API 3 — FR-15 `POST/PUT/DELETE /api/products` → tự chấm **30/30**

| Hạng mục | Yêu cầu | Đã làm | Chứng cứ |
|----------|---------|--------|----------|
| Generate (10) | ≥35 TC | **89 TC** (Domain 31 · State 8 · Security 21 · Schema 29) | `testcases/testcases_api3_extended.md` |
| Audit (5) | Gắn nhãn | 89 VALID · 0 INVALID (sửa 2 TC assert sai response) | `testcases/testcases_api3_extended.md` §Audit |
| Extend (5) | ≥5 TC | **5 TC** (gồm bug phá huỷ dữ liệu khi PUT một phần) | `testcases/testcases_api3_extended.md` |
| Execute (5) | Newman | 51 request · 125 assert · **89 pass / 36 fail** | `newman/newman-report-api3.html` |
| Bug (5) | Bug thật | **6 bug** (1 Critical: CRUD không xác thực) | `bugs/bug_report.md` |

### Agent Skill (AI-driven test generator) → tự chấm **10/10**

| Yêu cầu | Đã làm | Chứng cứ (trong bản nộp LMS) |
|---------|--------|------------------------------|
| Thiết kế pipeline sinh test bằng AI | 8 giai đoạn (Parse → Partition → Generate 4 nhóm → Coverage loop → Export) | `generator/test_generator_design.md` |
| Bản chạy tham chiếu | `python test_generator.py --demo` sinh `generated_collection.json` offline | `generator/test_generator.py` |
| Đóng gói skill tái sử dụng | Có `SKILL.md` (khi nào dùng, ràng buộc chống bịa, cách chạy) | `generator/SKILL.md` |
| Diagram pipeline | **Tự vẽ tay** (draw.io/giấy) theo mô tả §7 của design — không dùng AI vẽ | ảnh diagram trong bản nộp |
| Cơ chế chống LLM bịa | Grounding + JSON-Schema validation + Human audit gate + Expected≠Actual | design §4 |

**Tổng tự chấm: 100/100.**

---

## 4. Test Summary Report (mục 14 của đề)

**Số API kiểm thử: 3.**

| API | Endpoint | Generated (AI) | Added (extend) | Executed | Passed | Failed | Bugs |
|-----|----------|:--------------:|:--------------:|:--------:|:------:|:------:|:----:|
| API 1 | `GET /products/:id` | 64 | 6 | 181 | 146 | 35 | 8 |
| API 2 | `POST /apply-coupon` | 91 | 5 | 168 | 139 | 29 | 6 |
| API 3 | `POST/PUT/DELETE /products` | 89 | 5 | 125 | 89 | 36 | 6 |
| **Tổng** | — | **244** | **16** | **474** | **374** | **100** | **20** |

> **Cách đếm:** *Generated / Added* đếm ở mức **test case** (số AI sinh / số tự thêm khi extend). *Executed / Passed / Failed* đếm ở mức **assertion (check)** do Newman báo cáo. Ngoài ra API 2 còn **3 test case gắn nhãn BLOCKED** (không dựng được trạng thái cần hạ tầng: mã inactive, token hết hạn, toggle is_active) nên không nằm trong phần chạy tự động.

**3 bug Critical:** (1) SQLi ở `GET /api/products?search=` rút được email + mật khẩu plaintext; (2) FR-09 công thức percent tính ra `final_amount` lớn hơn cả tổng đơn (tiền âm); (3) FR-15 CRUD sản phẩm không yêu cầu xác thực — ai cũng sửa/xóa được.

> **Lưu ý đọc kết quả:** mọi assertion FAIL đều **assert theo spec (hành vi đúng)**, nên FAIL = phát hiện bug của SUT, **không phải** test sai. Chi tiết tách bạch "fail do bug logic" vs "an toàn trước injection" nằm trong từng `testcases_api*_extended.md` và `bug_report.md`.

---

## 5. Hướng dẫn tái hiện kết quả

> Yêu cầu: **Node.js 18+**, **Git**, **Postman**, và **Newman + reporter htmlextra**:
> ```bash
> npm install -g newman newman-reporter-htmlextra
> ```

### Bước 1 — Khởi động SUT (EShop)
Clone EShop SUT ra **ngoài** thư mục repo này, cài phụ thuộc và seed dữ liệu:
```bash
cd <thu-muc-sut>/backend
npm install
node database.js      # seed CSDL: tạo đúng 5 sản phẩm + user admin/test
node server.js        # server chạy tại http://localhost:3000
```
Kiểm tra server sống và DB đúng dữ liệu:
```bash
curl http://localhost:3000/api/products     # phải trả về 5 sản phẩm
```
> **Windows:** nếu `database.sqlite` bị khóa khi seed lại → tắt tiến trình cũ bằng `Get-Process node | Stop-Process -Force`, xóa `database.sqlite`, rồi `node database.js`.

### Bước 2 — Tài khoản seed sẵn (đã cấu hình trong environment)
| Vai trò | Email | Mật khẩu |
|--------|-------|----------|
| Admin | `admin@eshop.com` | `Admin123!` |
| User | `test@eshop.com` | `Test1234!` |

Collection tự đăng nhập để lấy token và tự gắn `X-Student-Id` — không cần thao tác tay.

### Bước 3A — Chạy bằng Newman (khuyến nghị, có báo cáo HTML)
Từ thư mục repo, chạy lần lượt 3 API (PowerShell cần đặt `cli,htmlextra` trong dấu nháy):
```bash
newman run postman/EShop_API1.postman_collection.json \
  -e postman/EShop_HW06.postman_environment.json \
  -r "cli,htmlextra" --reporter-htmlextra-export newman/newman-report-api1.html

newman run postman/EShop_API2.postman_collection.json \
  -e postman/EShop_HW06.postman_environment.json \
  -r "cli,htmlextra" --reporter-htmlextra-export newman/newman-report-api2.html

newman run postman/EShop_API3.postman_collection.json \
  -e postman/EShop_HW06.postman_environment.json \
  -r "cli,htmlextra" --reporter-htmlextra-export newman/newman-report-api3.html
```
Mở các file `newman/newman-report-*.html` để xem chi tiết pass/fail từng assertion.

### Bước 3B — Chạy bằng Postman GUI (nếu muốn xem trực quan)
1. Import 3 file trong `postman/*.postman_collection.json` và file `postman/EShop_HW06.postman_environment.json`.
2. Chọn environment **EShop-Local** ở góc phải.
3. Mở **Collection Runner** cho từng collection → **Run**.

> **Không cần reset DB giữa các lần chạy:** các TC tạo dữ liệu đều dùng hậu tố mã duy nhất `{{sfx}}` (sinh 1 lần ở pre-request cấp collection) để tránh đụng ràng buộc UNIQUE khi chạy lại. Muốn về trạng thái sạch tuyệt đối thì seed lại ở Bước 1.

---

## 6. Bằng chứng chống gian lận (đối chiếu khi chấm)

- **Định danh bài nộp:** mọi request mang header `X-Student-Id: 23127362` (xem tab Headers trong báo cáo Newman).
- **Chạy trên máy sinh viên:** báo cáo Newman ghi host `localhost` / `127.0.0.1:3000`.
- **Lịch sử làm bài:** các commit git tách theo từng bước (collection, testcases, newman, bugs, CI).
- **Diagram Agent Skill:** vẽ tay, không dùng AI sinh hình.
- **Trung thực kết quả:** báo cáo ghi cả assertion PASS lẫn FAIL; phân biệt rõ bug logic với phần SUT thực sự an toàn (parameterized query, verify JWT).

---

## 7. Bug report

Chi tiết 20 bug (tái hiện + chứng cứ mã nguồn + mức độ + tiêu chí SEC vi phạm) ở `bugs/bug_report.md`. Mỗi bug tương ứng 1 GitHub Issue trong repo; đính screenshot Newman/console vào `bugs/screenshots/`.
