# API 3 (FR-15) — EXTEND: Test case AI bỏ sót

> 5 TC ngoài 89 TC AI sinh, chọn từ vector AI bỏ sót + phân tích mã nguồn. Chạy `EShop_API3_Extend` để lấy số thật.

| TC_ID | Tiêu đề | Cách thực hiện | Kết quả (phân tích code) | Kết luận | Vì sao AI bỏ sót |
|-------|---------|----------------|--------------------------|----------|-------------------|
| **TC-API3-EXT-01** | PUT với body một phần XÓA MẤT các field khác | Tạo sản phẩm đủ field; PUT chỉ gửi `{"name":"X"}` | Handler: `UPDATE ... SET name=?,price=?,description=?,imageUrl=?,category_id=?` với các field thiếu = `undefined` → SQLite bind **NULL** → price/description/category_id **bị xoá thành null** | 🔴 **Bug mới nghiêm trọng**: cập nhật một phần phá huỷ dữ liệu (không PATCH-semantics, không giữ giá trị cũ) | AI test PUT bằng body **đầy đủ** (BODY_OK); không thử body thiếu field — kịch bản rất thực tế mà prompt không nêu |
| **TC-API3-EXT-02** | GET sản phẩm id chẵn trả `price` kiểu string | GET một sản phẩm có id chẵn vừa tạo | Code FR-06 `if(row.id%2===0) row.price=row.price.toString()` áp lên MỌI đọc sản phẩm → id chẵn `price` là chuỗi | 🔴 Bug chéo: sản phẩm tạo qua FR-15 khi đọc lại bị sai kiểu `price` nếu id chẵn | AI tách bạch FR-15 (ghi) khỏi FR-06 (đọc); không đối chiếu kiểu dữ liệu khi đọc lại sản phẩm vừa tạo |
| **TC-API3-EXT-03** | Trùng tên sản phẩm được chấp nhận | POST 2 sản phẩm cùng `name` | Không có ràng buộc UNIQUE trên name → cả 2 tạo được (200) | 🟡 Quan sát: spec không cấm trùng tên (đúng theo [ASSUMPTION] Bước 1), nhưng đáng ghi nhận cho BA — dễ gây nhầm ở FE | AI đã giả định name không unique nên không thiết kế TC xác minh chủ động |
| **TC-API3-EXT-04** | name cực dài (100.000 ký tự) — không giới hạn/DoS | POST với name 100k ký tự | Không validate độ dài ở CRUD → INSERT nguyên chuỗi 100k; không giới hạn payload | 🟠 Bug tiềm năng: không chặn payload lớn → rủi ro DoS / phình DB | AI phủ biên 256 (giả định spec ≤255) nhưng không thử biên "phá" vượt xa (100k) để lộ việc **không có** giới hạn thực tế |
| **TC-API3-EXT-05** | Method HEAD / OPTIONS trên /api/products | Gửi HEAD và OPTIONS | Express tự sinh HEAD từ GET → 200; OPTIONS tuỳ CORS → 200/204/404 | ✅ An toàn (không lộ thao tác ghi) | AI phủ PATCH (không hỗ trợ) nhưng bỏ HEAD/OPTIONS — biến thể method ít gặp |

## Nhận định "vì sao AI bỏ sót"
1. **Body đầy đủ vs một phần:** AI luôn PUT bằng body đủ field → bỏ lọt bug phá huỷ dữ liệu khi cập nhật một phần (EXT-01) — bug đáng giá nhất.
2. **Ranh giới đọc/ghi:** FR-15 là ghi, FR-06 là đọc; AI không đối chiếu kiểu dữ liệu khi đọc lại (EXT-02).
3. **Biên "phá" vượt xa:** AI dừng ở biên spec (255) mà không thử 100k để chứng minh **không có** giới hạn (EXT-04).
4. **Biến thể method:** HEAD/OPTIONS ngoài khung prompt (EXT-05).

## Ghi chú
EXT-01, EXT-02, EXT-04 là bug/rủi ro mới ngoài 6 bug bước chính → thêm vào `bug_report.md`. EXT-03 quan sát, EXT-05 an toàn. Báo cáo trung thực cả PASS lẫn FAIL.
