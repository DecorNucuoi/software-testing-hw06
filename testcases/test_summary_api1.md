# API 1 (FR-06) — Test Summary & Audit

**Endpoint:** `GET /api/products/:id` · SUT: EShop localhost:3000 · Runner: Newman
**Header mọi request:** `X-Student-Id: 23127362`

## Kết quả thực thi (Newman)

| Chỉ số | Giá trị |
|--------|---------|
| Test case thiết kế | 64 |
| Request thực thi (gồm setup + chained) | 68 |
| Tổng assertion | 181 |
| Assertion PASS | 146 |
| Assertion FAIL | 35 |

## Phân bố theo nhóm kỹ thuật

| Nhóm | Số TC |
|------|-------|
| Domain (EP+BVA) | 25 |
| State Transition | 12 |
| Security | 17 |
| Schema | 10 |
| **Tổng** | **64** |

## 35 assertion FAIL — TẤT CẢ là bug thật của SUT (không phải lỗi test)

Bộ test assert theo **spec** (hành vi đúng), nên FAIL = phát hiện lỗi. Phân 4 nhóm nguyên nhân:

### BUG-01 · Thiếu validate đầu vào + sai mã trạng thái (nghiêm trọng: TB, số lượng lớn nhất)
- **Hiện tượng:** id không tồn tại / id=0 / id âm / id=1.5 / id=abc / SQLi payload / path traversal... đều trả `200 + {}` thay vì `404`/`400`.
- **Chứng cứ code:** `app.get("/api/products/:id")` → `if(!row) return res.status(200).json({})`.
- **TC dính:** TC-004,005,006,007,008,009,011,012,013,014,015 (domain) + TC-027,030b,033b,034 (state) + TC-038,039,040,041,042,043,044,045,046,047,060,061 (security/schema).
- **Vi phạm:** chuẩn REST + chốt Q2. Không phải lỗ hổng bảo mật (xem BUG-04).

### BUG-02 · Sai kiểu dữ liệu `price` theo id chẵn/lẻ (nghiêm trọng: CAO)
- **Hiện tượng:** id chẵn (2,4) trả `price` kiểu **string** `"28000000"`; id lẻ trả `number`.
- **Chứng cứ code:** `if (row.id % 2 === 0) row.price = row.price.toString()`.
- **TC dính:** TC-002 ("dung kieu tung truong"), TC-062 ("price id=2 cung la number").
- **Tác động:** FE cộng chuỗi khi tính tổng giỏ hàng → sai tiền.

### BUG-03 · Cắt chuỗi tại null byte (nghiêm trọng: TB, rủi ro bypass filter)
- **Hiện tượng:** `GET /api/products/1%00` trả nguyên sản phẩm id=1 (chuỗi bị cắt tại `%00`).
- **TC dính:** TC-045 ("khong tra id=1 do cat null byte").

### BUG-04 · Response lỗi trả HTML + rò rỉ (nghiêm trọng: CAO — SEC-04)
- **Hiện tượng:** payload XSS → `404` kèm `Content-Type: text/html` và body `<!DOCTYPE html>...Cannot GET...` (phản chiếu payload).
- **TC dính:** TC-043 ("A-NOLEAK"), một phần TC-060/061.
- **Vi phạm:** SEC-04 + chốt Q2 (API JSON không được trả HTML).

## Xác nhận KHÔNG có lỗ hổng SQL Injection ở FR-06
Dù payload SQLi làm test FAIL (do BUG-01), endpoint **an toàn trước SQLi**: sau `DROP TABLE` bảng `products` vẫn đủ 5 bản ghi (TC-040b PASS), `UNION SELECT` không rút được cột nào. Nguyên nhân: dùng parameterized query `WHERE id = ?`. **SEC-05 ĐẠT.** → Trong bug report tuyệt đối không kết luận "FR-06 có SQLi".

## Bug phát sinh ngoài FR-06 (ghi nhận khi thao tác setup)
- **BUG-EXTRA-01 (nghiêm trọng nhất cả bài):** `GET /api/products?search=` (FR-05) nối chuỗi SQL → rút được email + mật khẩu plaintext bảng `users` qua endpoint public. Combo SEC-05 + SEC-01.
- **BUG-EXTRA-02:** mật khẩu lưu plaintext trong DB (SEC-01).
- **BUG-EXTRA-03:** `setup_guide.md` ghi sai mật khẩu admin (`admin123` vs `Admin123!`).

## Kết quả Audit test case do AI sinh (nhãn theo đề)
| Nhãn | Số TC | Ghi chú |
|------|-------|---------|
| VALID | 64 | Không TC nào bịa endpoint/field; mọi expected neo vào spec đã chốt |
| INVALID | 0 | — |
| INCOMPLETE (cần vá khi thực thi) | — | `{{runId}}` → thay bằng biến tĩnh; guard `BLOCKED` cho 11 TC state phụ thuộc FR-15 |
