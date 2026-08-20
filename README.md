# HW06 — API Testing (EShop SUT)

- **Sinh viên:** 23127362
- **Repository:** https://github.com/DecorNucuoi/software-testing-hw06
- **SUT:** [EShop](https://github.com/ttbhanh/eshop-sut) — chạy local tại `http://localhost:3000`
- **Công cụ:** Postman + Newman · AI: Claude
- **Header bắt buộc trên mọi request:** `X-Student-Id: 23127362`

---

## 1. API đã chọn

| # | Pool | FR | Tính năng | Endpoint |
|---|------|----|-----------|----------|
| API 1 | A | FR-06 | Xem chi tiết sản phẩm | `GET /api/products/:id` |
| API 2 | B | FR-09 | Áp dụng mã giảm giá | `POST /api/apply-coupon` |
| API 3 | C | FR-15 | Quản lý sản phẩm (CRUD) | `POST` / `PUT` / `DELETE /api/products` |

---

## 2. Test Summary Report

| Chỉ số | API 1 (FR-06) | API 2 (FR-09) | API 3 (FR-15) | Tổng |
|--------|---------------|---------------|---------------|------|
| Test case do AI sinh | _ | _ | _ | _ |
| Test case tự bổ sung | _ | _ | _ | _ |
| **Tổng test case** | _ | _ | _ | _ |
| Đã thực thi | _ | _ | _ | _ |
| Passed | _ | _ | _ | _ |
| Failed | _ | _ | _ | _ |
| Bug phát hiện | _ | _ | _ | _ |

**Phân bố theo kỹ thuật**

| Kỹ thuật | API 1 | API 2 | API 3 | Tổng |
|----------|-------|-------|-------|------|
| Domain partition (EP + BVA) | _ | _ | _ | _ |
| State transition | _ | _ | _ | _ |
| Security (SEC-01…SEC-07) | _ | _ | _ | _ |
| Schema validation | _ | _ | _ | _ |

**Kết quả audit test case do AI sinh**

| Nhãn | Số lượng | Tỷ lệ |
|------|----------|-------|
| VALID | _ | _ |
| INVALID | _ | _ |
| INCOMPLETE | _ | _ |

---

## 3. Bảng tự đánh giá (Self-Assessment)

| No. | Criteria | Grade | Self-Assessed Grade |
|-----|----------|-------|---------------------|
| 1 | API 1 (FR-06) — full pipeline: generate + audit + extend + execute + bugs | 30 | _ |
| 2 | API 2 (FR-09) — full pipeline | 30 | _ |
| 3 | API 3 (FR-15) — full pipeline | 30 | _ |
| 4 | Agent Skills (AI-driven test generator) | 10 | _ |
| | **Total** | **100** | **_** |

---

## 4. Cấu trúc thư mục

| Đường dẫn | Nội dung |
|-----------|----------|
| `report/` | Báo cáo chính (Markdown + PDF) |
| `postman/` | Collection, environment, data file cho data-driven run |
| `newman/` | Báo cáo Newman HTML |
| `testcases/` | Excel test case + test summary |
| `ai/` | AI Audit Report, AI Critique, log prompt thô |
| `generator/` | Thiết kế AI test generator: diagram tự vẽ + pseudocode |
| `cicd/` | CI/CD report + screenshot 2 lần chạy pipeline |
| `bugs/` | Bug report + screenshot, link GitHub Issues |
| `evidence/` | Screenshot Postman Console chứng minh header `X-Student-Id` |
| `.github/workflows/` | GitHub Actions chạy Newman |

---

## 5. Cách chạy lại bộ test

```powershell
# 1. Khởi động SUT
cd D:\eshop-sut_1\eshop-sut\backend
node database.js
node server.js

# 2. Chạy test (cửa sổ khác)
cd D:\HW06
newman run postman\EShop_HW06.postman_collection.json `
  -e postman\EShop_HW06.postman_environment.json `
  -r cli,htmlextra `
  --reporter-htmlextra-export newman\newman-report-full.html
```

---

## 6. Khai báo sử dụng AI

I use AI tools for the following tasks — chi tiết đầy đủ trong [`ai/AI_Audit_Report.md`](ai/AI_Audit_Report.md) và phần phê bình trong [`ai/AI_Critique.md`](ai/AI_Critique.md).
