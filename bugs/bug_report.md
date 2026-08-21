# EShop SUT — Bug Report (HW06)

- **Sinh viên:** 23127362 · **Repo:** https://github.com/DecorNucuoi/software-testing-hw06
- **Phát hiện trong quá trình test API 1 (FR-06 `GET /api/products/:id`)** và các endpoint phụ thuộc (setup).
- Mỗi bug dưới đây dùng làm 1 GitHub Issue (tiêu đề = heading). Đính kèm screenshot Newman/console vào `bugs/screenshots/`.

---

## BUG-01 · `GET /api/products/:id` không validate đầu vào, trả `200 {}` thay vì 400/404
- **Mức độ:** Medium · **Loại:** Correctness / API contract
- **Endpoint:** `GET /api/products/:id`
- **Tái hiện:**
  - `GET /api/products/999999` (id không tồn tại) → **200** `{}` (kỳ vọng 404)
  - `GET /api/products/0`, `/-1`, `/abc`, `/1.5` → **200** `{}` (kỳ vọng 400)
- **Kỳ vọng:** 404 cho id không tồn tại, 400 cho id sai định dạng, kèm body JSON `{error: "..."}`.
- **Thực tế:** luôn 200 với object rỗng.
- **Chứng cứ code:** `server.js` → `if (!row) return res.status(200).json({})`.
- **Tác động:** client không phân biệt được "không tìm thấy" với "thành công"; sai chuẩn REST.
- **Số TC phát hiện:** 20+ (TC-004,005,006,007,008,009,011...).

---

## BUG-02 · `price` trả sai kiểu dữ liệu theo id chẵn/lẻ
- **Mức độ:** High · **Loại:** Data type / contract
- **Endpoint:** `GET /api/products/:id`
- **Tái hiện:** `GET /api/products/1` → `"price": 30000000` (number); `GET /api/products/2` → `"price": "28000000"` (**string**).
- **Kỳ vọng:** `price` luôn là `number` (theo mẫu spec `"price": 100000`).
- **Chứng cứ code:** `if (row.id % 2 === 0) row.price = row.price.toString()`.
- **Tác động nghiêm trọng:** FE cộng chuỗi khi tính tổng giỏ hàng → sai số tiền (ví dụ `"28000000" + 1000 = "280000001000"`).
- **TC phát hiện:** TC-002, TC-062 (nhất quán kiểu liên bản ghi).

---

## BUG-03 · Cắt chuỗi tại null byte cho phép bypass bộ lọc
- **Mức độ:** Medium · **Loại:** Security (input handling)
- **Endpoint:** `GET /api/products/:id`
- **Tái hiện:** `GET /api/products/1%00` → **200** trả nguyên sản phẩm id=1 (chuỗi bị cắt tại `%00`).
- **Kỳ vọng:** 400/404 — không được cắt chuỗi.
- **Tác động:** kẻ tấn công có thể thêm `%00` để vượt qua bộ lọc chuỗi ở tầng ngoài.
- **TC phát hiện:** TC-045.

---

## BUG-04 · Response lỗi trả HTML + phản chiếu payload (không phải JSON)
- **Mức độ:** High · **Loại:** Security (SEC-04) / contract
- **Endpoint:** `GET /api/products/:id` (và mọi route không khớp)
- **Tái hiện:** `GET /api/products/<script>alert(1)</script>` → **404** với `Content-Type: text/html` và body `<!DOCTYPE html>...Cannot GET /api/products/<script>...` (phản chiếu payload chưa escape đúng ngữ cảnh HTML).
- **Kỳ vọng:** JSON `{error:...}`, `Content-Type: application/json`, không trả HTML.
- **Tác động:** vi phạm SEC-04; nền tảng cho XSS phản xạ nếu mở trực tiếp URL trên trình duyệt; lộ chuỗi Express mặc định.
- **TC phát hiện:** TC-043.

---

## BUG-05 · Gửi JSON sai cú pháp → trả HTML stack trace lộ đường dẫn máy chủ
- **Mức độ:** High · **Loại:** Security (information disclosure)
- **Endpoint:** bất kỳ endpoint parse body (phát hiện tại `POST /api/login`)
- **Tái hiện:** `POST /api/login` với body JSON hỏng → **HTML** `<pre>SyntaxError: ... at ...\eshop-sut_1\eshop-sut\backend\node_modules\body-parser\...`.
- **Kỳ vọng:** 400 JSON, không lộ stack trace / đường dẫn tuyệt đối.
- **Tác động:** lộ cấu trúc thư mục máy chủ, phiên bản thư viện.

---

## BUG-06 · [NGHIÊM TRỌNG NHẤT] SQL Injection ở `GET /api/products?search=` rút được mật khẩu plaintext
- **Mức độ:** Critical · **Loại:** Security (SEC-05 + SEC-01)
- **Endpoint:** `GET /api/products?search=` (FR-05 — endpoint phụ thuộc, dùng để lấy id khi test FR-06)
- **Tái hiện:**
  ```
  GET /api/products?search=zzz%' UNION SELECT id,email,password,role,'x',1 FROM users--
  ```
  → trả về:
  ```json
  [{"id":1,"name":"admin@eshop.com","price":"Admin123!","description":"admin",...},
   {"id":2,"name":"test@eshop.com","price":"Test1234!",...}]
  ```
- **Chứng cứ code:** `` const query = `SELECT * FROM products WHERE name LIKE '%${searchQuery}%'` `` (nối chuỗi trực tiếp).
- **Tác động:** rút toàn bộ bảng `users` gồm **email + mật khẩu plaintext** qua endpoint public, không cần đăng nhập. Đồng thời phơi bày **BUG-07** (mật khẩu lưu plaintext).
- **Ghi chú:** đối lập với `GET /api/products/:id` — endpoint đó dùng parameterized query nên an toàn. Chứng minh lỗ hổng khu trú ở `?search`.

---

## BUG-07 · Mật khẩu lưu plaintext trong CSDL
- **Mức độ:** Critical · **Loại:** Security (SEC-01)
- **Chứng cứ code:** `database.js` → `insertUser.run('Admin User','admin@eshop.com','Admin123!','admin')` (không hash).
- **Tác động:** kết hợp BUG-06 → lộ credential trực tiếp.

---

## BUG-08 · Tài liệu sai lệch: mật khẩu admin trong `setup_guide.md`
- **Mức độ:** Low · **Loại:** Documentation
- `setup_guide.md` ghi admin password = `admin123`, nhưng seed thực tế (`database.js`) là `Admin123!`.

---

## Bảng tổng hợp

| Bug | Mức độ | SEC vi phạm | Endpoint | Đã tạo Issue |
|-----|--------|-------------|----------|--------------|
| BUG-01 validate/status | Medium | — | GET /products/:id | ☐ |
| BUG-02 price sai kiểu | High | — | GET /products/:id | ☐ |
| BUG-03 null byte | Medium | SEC-05 (input) | GET /products/:id | ☐ |
| BUG-04 lỗi trả HTML | High | SEC-04 | GET /products/:id | ☐ |
| BUG-05 stack trace | High | info disclosure | body parser | ☐ |
| BUG-06 SQLi ?search | **Critical** | SEC-05+SEC-01 | GET /products?search | ☐ |
| BUG-07 plaintext pw | **Critical** | SEC-01 | database.js | ☐ |
| BUG-08 doc sai | Low | — | setup_guide.md | ☐ |

> Khi tạo GitHub Issue: mỗi bug 1 issue, dán mục tương ứng + screenshot Newman (bug 01–04), screenshot terminal (bug 05–06), screenshot code (bug 07). Tick cột "Đã tạo Issue" và dán link issue vào cột đó.

---

# BỔ SUNG — Bug phát hiện ở API 2 (FR-09 · POST /api/apply-coupon)

## BUG-A2-01 · [CRITICAL] Công thức percent tính ra tiền âm
- **Endpoint:** `POST /api/apply-coupon` · **Loại:** Business logic
- **Tái hiện:** `{"code":"SAVE10","total_amount":500000,"user_id":1}` (+ Bearer user) → `{"discount_amount":-4500000,"final_amount":5000000}`.
- **Kỳ vọng:** `discount_amount=50000`, `final_amount=450000` (10% của 500000).
- **Chứng cứ code:** `Math.floor(total_amount * (1 - coupon.discount_value))` — phải là `total * discount_value / 100`.
- **Tác động:** mọi mã `percent` tính sai; khách bị tính tiền âm khổng lồ → final vượt cả tổng đơn. Bug nặng nhất của bài.

## BUG-A2-02 · [Medium] Biên ngưỡng đơn hàng dùng `>` thay vì `>=`
- **Tái hiện:** SAVE10@300000 (đúng min), BIGBUY@500000 → **400** (từ chối).
- **Kỳ vọng:** 200 (spec: `total >= min_order_amount`). **Code:** `if (total_amount > coupon.min_order_amount)`.

## BUG-A2-03 · [High] apply-coupon không yêu cầu đăng nhập (SEC-02)
- **Tái hiện:** gọi không kèm `Authorization` → **200**, vẫn áp mã. **Kỳ vọng:** 401 (C4). **Code:** thiếu middleware `authenticateToken`.

## BUG-A2-04 · [High] IDOR — đếm lượt theo `user_id` trong body
- **Tái hiện:** user A hết lượt mã X; gửi `user_id` = id user B → áp dụng lại được. **Kỳ vọng:** dùng danh tính từ token (vẫn 400). Cho phép né hạn mức / tiêu lượt người khác.

## BUG-A2-05 · [High] Leo quyền admin (SEC-03)
- **Tái hiện:** token role=user gọi `POST /api/admin/coupons` → tạo được mã (200/201). `DELETE /api/admin/coupons/:id` tương tự. **Kỳ vọng:** 403. **Code:** `admin/coupons` chỉ kiểm token tồn tại, không kiểm `role='admin'`.

## Bảng tổng hợp API 2

| Bug | Mức độ | SEC | Đã tạo Issue |
|-----|--------|-----|--------------|
| BUG-A2-01 percent tiền âm | **Critical** | — | ☐ |
| BUG-A2-02 biên `>` vs `>=` | Medium | — | ☐ |
| BUG-A2-03 apply không auth | High | SEC-02 | ☐ |
| BUG-A2-04 IDOR user_id body | High | SEC-02 | ☐ |
| BUG-A2-05 leo quyền admin | High | SEC-03 | ☐ |
| BUG-A2-06 JSON hỏng → HTML stacktrace | High | info disclosure | ☐ |

> Ghi chú audit: đã chứng minh FR-09 **an toàn** trước SQLi (parameterized), JWT-forgery (verify OK trên GET /coupons), và mass-assignment (SEC-06 đạt). Các fail còn lại là bug **logic**, không phải lỗ hổng injection.

---

# BỔ SUNG — Bug phát hiện ở API 3 (FR-15 · POST/PUT/DELETE /api/products)

## BUG-A3-01 · [CRITICAL] CRUD sản phẩm không yêu cầu xác thực (SEC-02)
- **Tái hiện:** POST/PUT/DELETE `/api/products` **không kèm token** → vẫn tạo/sửa/xóa được (200/201). **Kỳ vọng:** 401. **Code:** route thiếu `authenticateToken`.
- **Tác động:** bất kỳ ai (kể cả ẩn danh) toàn quyền sửa danh mục sản phẩm.

## BUG-A3-02 · [High] Không kiểm quyền admin (SEC-03)
- **Tái hiện:** token role=user tạo/xóa sản phẩm → 200. **Kỳ vọng:** 403.

## BUG-A3-03 · [High] Không validate đầu vào (data integrity)
- **Tái hiện:** name rỗng / 256 ký tự, price = 0 / âm, category_id không tồn tại → **đều tạo được (200)**. **Kỳ vọng:** 400. **Code:** CRUD không có tầng validation nào.

## BUG-A3-04 · [Medium] PUT/DELETE id không tồn tại trả 200 thay vì 404
- **Tái hiện:** PUT/DELETE `/api/products/999999999` → 200. **Kỳ vọng:** 404.

## BUG-A3-05 · [High] import-products không atomic + không validate (FR-16)
- **Tái hiện:** import 3 dòng, dòng 2 `price=-100` → trả 200, dòng lỗi vẫn insert, các dòng khác cũng lưu (không rollback). **Kỳ vọng:** 400 + rollback toàn bộ. **Code:** `forEach` + `stmt.run` không transaction, chỉ validate `!row.name`.

## BUG-A3-06 · [High] JSON malformed → HTML stack trace
- Giống API 1/API 2 — body-parser trả HTML lỗi lộ đường dẫn máy chủ. **TC:** SCH-024.

## Bảng tổng hợp API 3

| Bug | Mức độ | SEC | Đã tạo Issue |
|-----|--------|-----|--------------|
| BUG-A3-01 CRUD không auth | **Critical** | SEC-02 | ☐ |
| BUG-A3-02 không kiểm role | High | SEC-03 | ☐ |
| BUG-A3-03 không validate input | High | — | ☐ |
| BUG-A3-04 PUT/DELETE 404 sai | Medium | — | ☐ |
| BUG-A3-05 import không rollback | High | — | ☐ |
| BUG-A3-06 JSON hỏng → HTML | High | info disclosure | ☐ |

> Ghi chú audit: FR-15 **an toàn** trước SQLi (parameterized, bảng products nguyên vẹn sau DROP) và SEC-04 (XSS lưu nguyên văn, escape thuộc FE). Cụm fail là do **thiếu validation + thiếu phân quyền**, không phải injection.

---

# TỔNG BUG TOÀN BÀI: 20 (API1: 8 · API2: 6 · API3: 6)
Trong đó Critical 3 (SQLi ?search lộ mật khẩu, percent tiền âm, CRUD không auth), còn lại High/Medium/Low.
