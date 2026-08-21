# API 2 (FR-09) — EXTEND: Test case AI bỏ sót

> 5 test case mở rộng ngoài 91 TC do AI sinh, chọn từ các vector AI **tự thú nhận bỏ sót** (7.3 mục 2, cuối Bước 4/5) + phân tích mã nguồn. Kết quả kỳ vọng suy từ code `server.js`; bạn chạy để lấy số thật.

| TC_ID | Tiêu đề | Cách thực hiện | Kết quả (phân tích từ code) | Kết luận | Vì sao AI bỏ sót |
|-------|---------|----------------|-----------------------------|----------|-------------------|
| **TC-API2-EXT-01** | Double-spend do TOCTOU trên hạn mức C5 | VIP100 (max=2) đã dùng 1; bắn **5 request `apply` đồng thời** ở mốc còn 1 lượt | Cả 5 đều đọc `COUNT=1 < 2` **trước khi** lượt nào được ghi → tất cả trả **200**. `apply-coupon` chỉ *đếm* `coupon_usage`, không ghi và không khóa; `coupon-usage` INSERT **không kiểm cap**. → vượt hạn mức | 🔴 **Bug thiết kế (race condition)** — kiểm C5 không nguyên tử | AI mô hình test tuyến tính (1 request/thời điểm), tự nhận 7.3: "mọi TC chạy tuần tự" |
| **TC-API2-EXT-02** | `final_amount` ÂM khi mã fixed > tổng đơn | Tạo mã `fixed, discount_value=999999, min=0`; apply với `total_amount=100000` | Code: `discount_amount = discount_value = 999999`; `final_amount = 100000 − 999999 = **−899999**`. Không có mệnh đề chặn trần | 🔴 **Bug mới**: thiếu clamp `discount ≤ total` / `final ≥ 0` (vi phạm chốt e) | AI có thiết kế FC-12 (TESTOVER) nhưng để "200 hoặc 400" — chưa khẳng định code thực tế trả **final âm**; đây là xác nhận bằng mã nguồn |
| **TC-API2-EXT-03** | Tạo trùng `code` → 500 + lộ lỗi SQL | Admin tạo lại mã `SAVE10` (đã tồn tại) | `code` là cột UNIQUE → INSERT lỗi → handler `return res.status(500).json({error: err.message})` → **500** kèm `"SQLITE_CONSTRAINT: UNIQUE constraint failed: coupons.code"` | 🔴 **Bug mới**: sai mã trạng thái (nên 409 Conflict) + **rò rỉ lỗi SQL nội bộ** (information disclosure) | AI chỉ test *áp dụng* mã, không test *tạo trùng* trên endpoint admin — ngoài luồng apply-coupon mà nó tập trung |
| **TC-API2-EXT-04** | `coupon-usage` nhận `coupon_id` không tồn tại (thiếu FK) | Gọi `POST /api/coupon-usage` với `coupon_id=999999` | Code: INSERT thẳng, bảng `coupon_usage` **không có ràng buộc khóa ngoại** → trả **200 "Usage recorded"**, tạo bản ghi lượt-dùng **mồ côi** | 🟠 **Bug toàn vẹn dữ liệu**: ghi lượt cho mã không tồn tại; có thể làm lệch bộ đếm nếu id được tái cấp | Vector cross-endpoint (endpoint phụ), không nằm trong tham số của apply-coupon mà prompt mô tả |
| **TC-API2-EXT-05** | HTTP Method Override bị bỏ qua | `POST /api/apply-coupon` + header `X-HTTP-Method-Override: DELETE` | Express không nạp middleware method-override → coi là POST bình thường → **200**, không xóa gì | ✅ An toàn (header bị bỏ qua) | AI phủ method qua HTTP verb, bỏ sót kỹ thuật override header — không có trong danh sách phân vùng method |

## Nhận định "vì sao AI bỏ sót" (tổng quát)
1. **Ranh giới endpoint:** AI tập trung đúng `apply-coupon` như đề yêu cầu, nên bỏ các lỗ hổng ở **endpoint phụ** (tạo trùng mã ở admin/coupons — EXT-03; toàn vẹn ở coupon-usage — EXT-04).
2. **Mô hình tuyến tính:** không tự sinh test đồng thời → bỏ race condition (EXT-01).
3. **Spec im lặng về clamp:** AI để ngỏ nhánh 200/400 cho fixed>total; chỉ khi đọc code mới khẳng định final âm (EXT-02).
4. **Kỹ thuật ngoài khung prompt:** method-override header (EXT-05).

## Ghi chú
EXT-01..04 là **bug thật mới** (ngoài 6 bug đã tìm ở bước chính) — bổ sung vào `bug_report.md`. EXT-05 an toàn (báo cáo trung thực). Chạy collection `EShop_API2_Extend` để lấy số thật của máy bạn.
