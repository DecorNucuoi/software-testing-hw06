# API 1 (FR-06) — EXTEND: Test case AI bỏ sót

> Yêu cầu đề (bước 3): thêm ≥5 test case AI không sinh, giải thích **vì sao AI bỏ sót**. Mọi TC dưới đây đã **chạy thật** trên SUT localhost:3000.

| TC_ID | Tiêu đề | Method + Payload | Kết quả thật | Kết luận | Vì sao AI bỏ sót |
|-------|---------|------------------|--------------|----------|-------------------|
| **TC-API1-EXT-01** | Time-based blind SQL Injection | `GET /api/products/1 AND 1=(SELECT randomblob(200000000))` | status 200, thời gian **0.014s** (không trễ) | ✅ An toàn — parameterized query, không thực thi payload | AI ở P5 chỉ sinh SQLi *boolean-based* (TC-042). Time-based là kỹ thuật khai thác được **cả khi response luôn giống nhau** — AI tự thú nhận thiếu ở phần 7.3 mục 2. Giới hạn của prompt: P5 liệt kê "tautology/stacking/UNION/blind boolean" nhưng không nêu time-based. |
| **TC-API1-EXT-02** | Stored XSS qua dữ liệu sản phẩm | Tạo product `name=<script>alert(1)</script>` rồi `GET /api/products/:id` | status 200, `Content-Type: application/json`, `name` trả **nguyên văn** trong chuỗi JSON hợp lệ | ✅ ĐẠT ở tầng API (trả data thô, không render HTML). Rủi ro chuyển sang FE nếu render bằng `innerHTML` | AI ở P5 chỉ bơm XSS qua **path param** (TC-043). Vector nguy hiểm hơn là payload **được lưu** rồi phát tán qua GET — cần tạo dữ liệu trước (POST), mà endpoint đang test là GET nên AI coi ngoài phạm vi. Đặc thù API: nguồn XSS thật nằm ở dữ liệu, không ở tham số. |
| **TC-API1-EXT-03** | HTTP Method Override header | `GET /api/products/1` + `X-HTTP-Method-Override: DELETE` | status 200, id=1 **vẫn tồn tại** | ✅ An toàn — header override bị bỏ qua | AI phủ method qua HTTP verb thật (P3: PATCH/TRACE/HEAD) nhưng bỏ sót **override header** — kỹ thuật vượt tường lửa/proxy chỉ chặn theo verb. Không có trong danh sách phân vùng method ở P2. |
| **TC-API1-EXT-04** | Nén nội dung (Accept-Encoding: gzip) | `GET /api/products/1` + `Accept-Encoding: gzip` | status 200, trả bình thường | ✅ Hoạt động | Chiều phi chức năng (hiệu năng/vận chuyển). AI thừa nhận 7.3 mục 1: "không có chiều phi chức năng nào". Prompt tập trung correctness, không đề cập transport optimization. |
| **TC-API1-EXT-05** | Race condition — 20 GET song song | 20 request đồng thời `GET /api/products/1` | 20/20 trả 200, ổn định | ✅ Không có lỗi đồng thời trên đường đọc | AI tự nhận 7.3 mục 2: "mọi TC chạy tuần tự, một request một thời điểm". Không mô hình hóa concurrency vì bản chất bảng test case tuyến tính. |
| **TC-API1-EXT-06** | Định tuyến double-slash `//` | `GET /api/products//1` | status **404** | ✅ Không nhầm route | AI có phủ id rỗng `/products/` (TC-009) nhưng không phủ **double-slash giữa path** — biến thể chuẩn hóa URL mà nhiều framework xử lý khác nhau. Biên định tuyến hiếm, ngoài danh sách phân vùng. |

## Nhận định tổng quát về "vì sao AI bỏ sót"
1. **Prompt quyết định độ phủ:** AI chỉ sinh những vector được liệt kê trong prompt P2/P5. Vector không được gọi tên (time-based SQLi, method override) thì không xuất hiện — đúng bản chất "AI làm theo hướng dẫn, không tự mở rộng ngoài khung".
2. **Ranh giới endpoint:** GET là điểm *đọc*, nên các lỗ hổng cần *ghi* trước (stored XSS) bị AI xếp ngoài phạm vi — hợp lý về mặt logic nhưng bỏ lọt rủi ro thực tế.
3. **Chiều phi chức năng:** AI (và bảng test case dạng tuyến tính) không tự nhiên mô hình hóa hiệu năng, tải, đồng thời. Đây là giới hạn cấu trúc, không phải giới hạn kiến thức.

## Ghi chú cho báo cáo
6 TC extend này **PASS** (hệ thống an toàn ở các vector này) — điều đó vẫn hợp lệ và cần báo cáo trung thực. Giá trị của extend không nằm ở việc "phải tìm ra bug", mà ở việc **mở rộng lớp lỗi được kiểm tra** vượt khỏi khung prompt ban đầu.
