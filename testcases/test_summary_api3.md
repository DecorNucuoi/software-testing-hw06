# API 3 (FR-15) — Test Summary & Audit

**Endpoint:** `POST/PUT/DELETE /api/products` (+ GET đối chiếu, `POST /api/admin/import-products`) · SUT localhost:3000 · Runner: Newman · Header mọi request: `X-Student-Id: 23127362`

## Thiết kế test (Generate)

| Nhóm | Số TC thiết kế |
|------|----------------|
| Domain (EP+BVA name/price/category_id/:id) | 31 |
| State (vòng đời sản phẩm + cách ly + import rollback) | 8 |
| Security (SEC-02/03/04/05, phân quyền, XSS, SQLi) | 21 |
| Schema (thiếu field, sai kiểu, malformed, method) | 29 |
| **Tổng** | **89** phủ 80/80 phân vùng |

## Thực thi (collection lõi)

| Chỉ số | Giá trị |
|--------|---------|
| Request | 51 (+3 sendRequest phụ) |
| Assertion | 125 |
| PASS | 89 |
| FAIL | 36 |

## 36 FAIL — TẤT CẢ là bug thật. FR-15 gần như KHÔNG có tầng validation & phân quyền

### BUG-A3-01 · [CRITICAL] CRUD sản phẩm KHÔNG yêu cầu xác thực (SEC-02)
- POST/PUT/DELETE `/api/products` **không có middleware auth** → không token vẫn tạo/sửa/xóa được (trả 200/201).
- **Chứng cứ code:** `app.post/put/delete("/api/products"...)` thiếu `authenticateToken`.
- **TC:** SEC-001 (POST no-token→200), SEC-003 (DELETE no-token→200).

### BUG-A3-02 · [High] Không kiểm quyền admin (SEC-03)
- Vì không có auth, token user thường cũng tạo/xóa được → leo thang đặc quyền.
- **TC:** SEC-004, SEC-006 (user token → 200 thay vì 403).

### BUG-A3-03 · [High] KHÔNG validate đầu vào (data integrity)
- name rỗng / toàn khoảng trắng / 256 ký tự, price = 0 / âm, category_id không tồn tại / = 0 → **đều tạo được (200)** thay vì 400.
- **TC:** D-003,004,007,009,010,017,018 + SCH-001,002,003,004,008,009,010,023,026.
- Không có tầng kiểm tra field nào ở CRUD sản phẩm.

### BUG-A3-04 · [Medium] PUT/DELETE id không tồn tại trả 200 thay vì 404
- Sửa/xóa sản phẩm không tồn tại → SUT vẫn trả 200 (0 dòng bị ảnh hưởng, không báo lỗi).
- **TC:** D-021, D-022, S-004, S-005, SCH-013.

### BUG-A3-05 · [High] import-products KHÔNG atomic + không validate (FR-16)
- Handler chỉ check thiếu `name`; price âm / category sai **vẫn insert**; không transaction → **không rollback**; luôn trả 200 kèm `"Import hoàn tất"`.
- **TC:** S-007 (1 dòng price âm → kỳ vọng 400 + rollback; thực tế 200 + dòng vẫn lưu).
- **Chứng cứ code:** `rows.forEach(... stmt.run ...)` không bọc transaction, chỉ validate `!row.name`.

### BUG-A3-06 · [High] JSON malformed → HTML stack trace (information disclosure)
- Body JSON hỏng → trang HTML lỗi của body-parser, lộ đường dẫn máy chủ.
- **TC:** SCH-024. Cùng lớp bug toàn cục với API 1/API 2.

## Xác nhận KHÔNG có lỗ hổng ở tầng SQL/XSS-API
- **SEC-05 (SQLi) ĐẠT:** payload qua `:id` và field body được parameterized → coi là chuỗi/không khớp; bảng `products` nguyên vẹn sau `DROP TABLE` (SEC-017b PASS); không rút được bảng khác.
- **SEC-04 ĐẠT ở tầng API:** name/description chứa `<script>` được lưu & trả nguyên văn JSON (đúng — escape thuộc FE); Content-Type luôn `application/json`.

→ Phân biệt: fail của FR-15 là do **thiếu validation + thiếu auth** (bug logic/thiết kế), KHÔNG phải lỗ hổng injection.

## Audit test case AI sinh
| Nhãn | Số | Ghi chú |
|------|-----|---------|
| VALID | 89 | Không bịa; expected neo vào chốt spec FR-15 |
| INVALID | 0 | — |
| Ghi chú | — | 2 TC (SEC-014/019) ban đầu assert `name` trên response POST (SUT chỉ trả `{message,id}`) → đã sửa verify qua GET |
