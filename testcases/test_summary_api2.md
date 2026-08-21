# API 2 (FR-09) — Test Summary & Audit

**Endpoint:** `POST /api/apply-coupon` · SUT localhost:3000 · Runner: Newman · Header mọi request: `X-Student-Id: 23127362`

## Thiết kế test (Generate P0–P6)

| Nhóm | Số TC thiết kế |
|------|----------------|
| Domain (EP+BVA + Decision Table 17 rule + Formula 17 ca) | 56 |
| State Transition (vòng đời mã + lượt tích lũy) | 9 |
| Security (SQLi×6, IDOR×2, SEC-03, JWT, mass-assign) | 19 |
| Schema & Robustness | 10 |
| **Tổng** | **91** (3 BLOCKED: mã inactive, token hết hạn, toggle is_active) |

## Thực thi (collection lõi chạy được)

| Chỉ số | Giá trị |
|--------|---------|
| Request thực thi (gồm setup + chuỗi + extend) | 69 |
| Assertion | 168 |
| PASS | 139 |
| FAIL | 29 | (24 chính + 5 extend: final âm, trùng-code lộ SQL, usage mồ côi, race, method-override an toàn) |

*(Collection lõi phủ 4 nhóm + mọi bug; 91 TC đầy đủ nằm trong CSV/Excel. Các TC BLOCKED và biến thể payload đưa vào tài liệu, không chạy tự động.)*

## 24 FAIL — tất cả là BUG THẬT (assert theo spec = phát hiện lỗi)

### BUG-A2-01 · Công thức percent SAI NGHIÊM TRỌNG — tính ra tiền âm (nghiêm trọng: CRITICAL)
- **Hiện tượng:** `SAVE10` (percent 10%) @500000 → `discount_amount: -4500000`, `final_amount: 5000000`. Khách phải trả **5 triệu** cho đơn 500k.
- **Chứng cứ code:** `discount_amount = Math.floor(total_amount * (1 - coupon.discount_value))` → `500000 × (1 − 10) = −4.5tr`. Đúng phải là `total × discount_value / 100`.
- **TC:** TC-001, TC-002, TC-003 (mọi mã percent). Mã `fixed` (BIGBUY/VIP100) KHÔNG dính (chỉ lấy `discount_value`).

### BUG-A2-02 · Biên C3 dùng `>` thay vì `>=` (nghiêm trọng: Medium)
- **Hiện tượng:** total = đúng `min_order_amount` bị từ chối 400. SAVE10@300000, BIGBUY@500000 → 400 (spec: phải 200).
- **Chứng cứ code:** `if (total_amount > coupon.min_order_amount)`.
- **TC:** TC-003, TC-006 (và ảnh hưởng mọi ca @đúng ngưỡng).

### BUG-A2-03 · apply-coupon KHÔNG yêu cầu xác thực (nghiêm trọng: High — SEC-02 + C4)
- **Hiện tượng:** không gửi token → **200**, vẫn áp mã (spec/C4: phải 401).
- **Chứng cứ code:** route `apply-coupon` không có middleware `authenticateToken`.
- **TC:** TC-041, TC-043.

### BUG-A2-04 · IDOR — đếm lượt C5 theo `user_id` trong body, không theo token (nghiêm trọng: High)
- **Hiện tượng:** user A hết lượt, đổi `user_id` sang id user B → áp dụng lại được (né hạn mức).
- **Chứng cứ code:** dùng `user_id` từ body cho truy vấn `coupon_usage`, không lấy từ JWT.
- **TC:** SEC-009.

### BUG-A2-05 · Leo quyền — user thường tạo/xóa được mã giảm giá (nghiêm trọng: High — SEC-03)
- **Hiện tượng:** token role=user gọi `POST /api/admin/coupons` → **200/201**, tạo được mã (spec: 403).
- **Chứng cứ code:** `admin/coupons` chỉ có `authenticateToken`, không kiểm `role='admin'`.
- **TC:** SEC-011.

### BUG-A2-06 · JSON sai cú pháp → trả HTML stack trace (nghiêm trọng: High — information disclosure)
- **Hiện tượng:** body JSON hỏng → HTML `<!DOCTYPE html>...SyntaxError...` lộ đường dẫn máy chủ.
- **TC:** SCH-006. (Cùng lớp bug với API 1 BUG-05 — lỗi toàn cục ở body-parser.)

## Xác nhận KHÔNG có lỗ hổng SQLi / JWT ở FR-09
- SQLi qua `code`/`total_amount`: parameterized query → payload coi là chuỗi, trả 404/400, bảng `coupons` nguyên vẹn sau `DROP TABLE` (SEC-004b PASS). **SEC-05 ĐẠT.**
- JWT sai chữ ký / `alg:none` trên `GET /api/coupons`: bị từ chối 403 (SEC-014/015 PASS). **Cơ chế verify JWT ĐẠT** — điểm yếu chỉ là `apply-coupon` quên gắn middleware (BUG-A2-03).
- Mass-assignment (SEC-017): body `discount_value` bị bỏ qua, discount theo CSDL → **SEC-06 ĐẠT**.

→ Trong bug report: phân biệt rõ "fail do bug logic (công thức/biên/auth)" với "an toàn trước SQLi/JWT-forgery".

## Audit test case AI sinh
| Nhãn | Số | Ghi chú |
|------|-----|---------|
| VALID | 91 | Không bịa; expected neo vào chốt spec (a)-(i) + CH-01..08 |
| INVALID | 0 | — |
| BLOCKED | 3 | mã inactive (không có API set is_active), token hết hạn (không ép được TTL), toggle is_active |
