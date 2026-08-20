# HW06 — BỘ PROMPT ĐIỀU KHIỂN AI GEN TEST CASE
### Tối ưu cho **Claude (web/app)** · Dùng lại cho cả 3 API

---

## Cách dùng

- Mỗi API = **1 chat mới** trong Claude (đừng trộn 3 API vào 1 chat → context nhiễu, AI trộn endpoint).
- Trình tự: `P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8 → P9`.
- **Mỗi prompt là một bước kỹ thuật riêng**, đúng yêu cầu "drive the AI step by step, not a single generic prompt" của đề. Đừng gộp.
- Sau **mỗi** output: dán về cho tôi → tôi audit → tôi đưa `FIX` prompt nếu cần.
- Sau mỗi lượt, lưu file: `ai/prompts/api1_p1_prompt.md` và `ai/prompts/api1_p1_output.md`. Ghi kèm **ngày giờ** — AI Audit Report cần.

**Ký hiệu cần thay:** chỉ còn `{{API_CARD}}` — dán nguyên khối API Card tương ứng ở Phần B vào đó. MSSV `23127362` đã điền sẵn.

---

# PHẦN A — CÁC PROMPT

## P0 — Nạp ngữ cảnh & giao kèo output (chạy 1 lần đầu mỗi chat)

```text
Bạn đóng vai một Test Analyst kỳ cựu (ISTQB Advanced) chuyên về API testing. Chúng ta sẽ cùng thiết kế bộ test case cho MỘT API duy nhất của hệ thống EShop, theo đúng quy trình kỹ thuật kiểm thử, TỪNG BƯỚC MỘT.

<quy_tac_bat_buoc>
1. Chỉ làm ĐÚNG bước tôi yêu cầu trong mỗi tin nhắn. TUYỆT ĐỐI không nhảy trước sang bước sau. Nếu tôi hỏi phân vùng, đừng sinh test case.
2. Nguồn sự thật duy nhất là <spec> tôi cung cấp. KHÔNG được bịa endpoint, trường dữ liệu, mã lỗi hay quy tắc nghiệp vụ không có trong spec.
3. Khi spec KHÔNG nói rõ về một tình huống, bạn phải đánh dấu rõ ràng bằng nhãn [ASSUMPTION] và nêu lý do suy luận, thay vì im lặng tự quyết.
4. Phân biệt rành mạch hai khái niệm: "expected theo SPEC" (hệ thống PHẢI làm gì) khác với "actual behaviour" (hệ thống đang làm gì). Bạn chưa chạy hệ thống, nên cột kỳ vọng LUÔN lấy theo spec.
5. Không viết lời mở đầu, không tóm tắt lại yêu cầu của tôi, không kết luận dài dòng. Trả lời đi thẳng vào sản phẩm của bước đó.
6. Mọi bảng phải ở định dạng Markdown table.
</quy_tac_bat_buoc>

<spec>
{{API_CARD}}
</spec>

<bien_moi_truong>
- Base URL: http://localhost:3000
- Mọi request đều tự động mang header: X-Student-Id: 23127362
- Tài khoản admin: admin@eshop.com / Admin123! (role=admin)
- Tài khoản user thường: test@eshop.com / Test1234! (role=user)
- Lấy JWT: POST /api/login với body {"email": "...", "password": "..."}
</bien_moi_truong>

Nếu bạn đã đọc và hiểu, hãy trả lời DUY NHẤT bằng một bảng 2 cột tóm tắt:
| Hạng mục | Nội dung tôi đã nắm |
gồm đúng 5 dòng: (1) API đang test, (2) danh sách tham số đầu vào, (3) các ràng buộc nghiệp vụ, (4) các yêu cầu bảo mật liên quan, (5) những điểm spec còn mơ hồ.
Không viết gì thêm.
```

---

## P1 — Kiểm kê hợp đồng API (chưa sinh test case)

```text
BƯỚC 1 — KIỂM KÊ HỢP ĐỒNG API (Contract Inventory).

Chưa sinh test case. Chỉ lập bảng kiểm kê ĐẦY ĐỦ mọi thành phần đầu vào/đầu ra của API này.

Bảng 1 — Tham số đầu vào:
| ID | Tên tham số | Vị trí (path/query/body/header) | Kiểu dữ liệu | Bắt buộc? | Ràng buộc theo spec | Trích dẫn spec | Độ mơ hồ (Cao/TB/Thấp) |

Bảng 2 — Đầu ra kỳ vọng:
| Mã trạng thái | Khi nào xảy ra | Cấu trúc response (tên trường : kiểu) | Trích dẫn spec |

Bảng 3 — Phụ thuộc & tiền điều kiện:
| ID | Phụ thuộc (dữ liệu/endpoint/quyền) | Cách thiết lập | Cách dọn dẹp sau test |

Yêu cầu:
- Liệt kê CẢ những tham số ẩn: header Authorization, Content-Type, và header X-Student-Id.
- Cột "Trích dẫn spec" phải dẫn đúng câu chữ trong <spec>. Nếu spec không có → ghi "KHÔNG CÓ TRONG SPEC" và đánh Độ mơ hồ = Cao.
- Cuối cùng liệt kê riêng một mục "CÂU HỎI CHO SPEC": tối thiểu 5 điểm spec chưa định nghĩa mà một tester bắt buộc phải làm rõ trước khi test.
```

---

## P2 — Phân vùng tương đương + Phân tích giá trị biên

```text
BƯỚC 2 — PHÂN VÙNG TƯƠNG ĐƯƠNG (Equivalence Partitioning) VÀ GIÁ TRỊ BIÊN (Boundary Value Analysis).

Vẫn CHƯA sinh test case. Chỉ phân vùng.

Với TỪNG tham số đã liệt kê ở Bảng 1 của Bước 1 (không bỏ sót tham số nào, kể cả header), hãy lập:

| Param | Mã phân vùng | Loại (Hợp lệ/Không hợp lệ) | Mô tả lớp tương đương | Giá trị đại diện | Là biên? | Lý do chọn |

Quy ước mã phân vùng: EP-<TÊNPARAM>-V1, EP-<TÊNPARAM>-I1, ... ; biên dùng BV-<TÊNPARAM>-1, ...

Yêu cầu bắt buộc:
- Mỗi tham số phải có TỐI THIỂU 1 lớp hợp lệ và 3 lớp không hợp lệ.
- Với tham số số: áp dụng biên 2-value và 3-value — nêu rõ min-1, min, min+1, max-1, max, max+1. Nếu spec không cho max, ghi [ASSUMPTION] và đề xuất giới hạn kỹ thuật (ví dụ tràn số nguyên 32-bit, JS Number.MAX_SAFE_INTEGER).
- Với tham số chuỗi: phân vùng theo độ dài (rỗng, 1 ký tự, độ dài tối đa, vượt tối đa) VÀ theo tập ký tự (ASCII, tiếng Việt có dấu, emoji, khoảng trắng đầu/cuối, ký tự điều khiển).
- Với tham số kiểu ID: bao gồm không tồn tại, số âm, số 0, không phải số, rất lớn, null, mảng, object.
- Với tham số kiểu tiền: bao gồm 0, số âm, số thập phân, chuỗi số, độ chính xác dấu phẩy động.
- Bổ sung một mục riêng: phân vùng cho TRẠNG THÁI XÁC THỰC (không có token / token sai định dạng / token hết hạn / token user thường / token admin).

Kết thúc bằng một dòng đếm: tổng số phân vùng theo từng tham số.
```

---

## P3 — Sinh test case miền giá trị

```text
BƯỚC 3 — SINH TEST CASE MIỀN GIÁ TRỊ (Domain Partition Test Cases).

Bây giờ mới sinh test case, và CHỈ cho nhóm domain (chưa làm security, chưa làm state transition, chưa làm schema).

Mỗi phân vùng ở Bước 2 phải được phủ bởi ít nhất một test case. Dùng đúng bảng sau:

| TC_ID | FR | Kỹ thuật | Nhóm | Tiêu đề test | Tiền điều kiện | Method + Endpoint | Headers | Request body / params | Expected HTTP | Expected response / Assertion | Truy vết (mã phân vùng) | Ưu tiên |

Quy ước:
- TC_ID: TC-<APIID>-D-001 tăng dần (D = Domain).
- Kỹ thuật: ghi rõ "EP" hoặc "BVA" hoặc "EP+BVA".
- Nhóm: luôn là "Domain".
- "Expected response / Assertion": viết ở dạng KIỂM CHỨNG ĐƯỢC, ví dụ: 'body.price là kiểu number VÀ > 0', không viết chung chung như 'trả về đúng'.
- Truy vết: liệt kê mã EP-/BV- mà test case này phủ.
- Ưu tiên: Cao/Trung bình/Thấp, kèm lý do ngắn ở cuối bảng cho các case Cao.

Yêu cầu số lượng: TỐI THIỂU 18 test case cho nhóm domain.

Sau bảng, thêm một MA TRẬN PHỦ:
| Mã phân vùng | Được phủ bởi TC nào | Đã phủ? |
và liệt kê rõ phân vùng nào CHƯA được phủ (nếu có).
```

---

## P4 — Test case chuyển trạng thái

```text
BƯỚC 4 — TEST CASE CHUYỂN TRẠNG THÁI (State Transition Testing).

Chỉ làm state transition. Không lặp lại test case của Bước 3.

Phần 4.1 — Mô hình trạng thái:
Xác định các thực thể có trạng thái liên quan đến API này và vẽ bảng chuyển trạng thái:
| Trạng thái hiện tại | Sự kiện / API gọi | Trạng thái đích | Hợp lệ hay không | Kỳ vọng khi gọi sai |

Bối cảnh trạng thái của hệ thống EShop:
- FR-10 — Vòng đời đơn hàng có 5 trạng thái: pending → confirmed → shipping → delivered, và canceled.
  Chuyển trạng thái do admin thực hiện qua PUT /api/admin/orders/:id/status.
  Người dùng hủy đơn qua PUT /api/orders/:id/cancel, CHỈ được hủy khi đơn CHƯA giao.
- Ngoài ra, hãy tự xác định trạng thái riêng của thực thể mà API tôi đang test tác động lên (ví dụ: vòng đời tài nguyên tồn tại → đã sửa → đã xóa; hoặc số lượt dùng mã giảm giá của một user: 0 lượt → đã dùng hết lượt).

Phần 4.2 — Test case, dùng đúng bảng của Bước 3, với:
- TC_ID: TC-<APIID>-S-001 (S = State)
- Nhóm: "State Transition"
- Thêm cột "Chuỗi request" mô tả các bước gọi API tuần tự để đưa hệ thống về trạng thái cần thiết.

Yêu cầu bắt buộc:
- Phủ đủ CẢ chuyển trạng thái HỢP LỆ lẫn chuyển trạng thái KHÔNG HỢP LỆ (ví dụ nhảy cóc pending → delivered, hoặc thao tác trên tài nguyên đã bị xóa).
- Có ít nhất 2 test case dạng "0-switch" và 2 test case dạng "1-switch" (chuỗi 2 chuyển tiếp liên tiếp).
- Có ít nhất 1 test case về tính bền vững: gọi lặp cùng một thao tác 2 lần (idempotency).
- TỐI THIỂU 8 test case.
```

---

## P5 — Test case bảo mật (SEC-01 … SEC-07)

```text
BƯỚC 5 — TEST CASE BẢO MẬT.

Chỉ làm security. Đây là các yêu cầu bảo mật chính thức của SUT:

SEC-01: Mật khẩu KHÔNG được lưu dạng plaintext.
SEC-02: Các API có tính bảo mật phải yêu cầu JWT Token hợp lệ.
SEC-03: API Admin phải kiểm tra role = 'admin' trong Token, không chỉ kiểm tra sự tồn tại của Token.
SEC-04: Mọi dữ liệu người dùng nhập khi hiển thị trên UI phải được escape đúng cách, không dùng innerHTML trực tiếp.
SEC-05: Truy vấn CSDL phải dùng Parameterized Query, không nối chuỗi trực tiếp.
SEC-06: API cập nhật hồ sơ không được cho phép thay đổi trường role từ client.
SEC-07: OTP đặt lại mật khẩu phải đủ entropy (tối thiểu 6 chữ số), có thời hạn và vô hiệu hóa sau khi dùng.

Nhiệm vụ:
Phần 5.1 — Bảng áp dụng: với từng SEC-01..SEC-07, nêu API tôi đang test có liên quan hay không, và liên quan như thế nào.
| SEC | Có áp dụng cho API này? | Lý do | Vector tấn công cụ thể |

Phần 5.2 — Test case, dùng đúng bảng của Bước 3, với TC_ID: TC-<APIID>-SEC-001, Nhóm: "Security", và thêm cột "SEC ID".

Bắt buộc phủ tối thiểu các nhóm tấn công sau, mỗi nhóm ≥ 1 test case:
a) Thiếu token hoàn toàn.
b) Token sai định dạng / bị sửa chữ ký / hết hạn.
c) Leo thang đặc quyền: dùng token của user thường gọi endpoint dành cho admin.
d) IDOR: thao tác trên tài nguyên của user khác bằng cách đổi id trong path hoặc trong body.
e) SQL Injection: payload dạng ' OR '1'='1, '; DROP TABLE --, UNION SELECT, và biến thể mã hóa URL.
f) Mass assignment: chèn thêm trường không được phép vào body (ví dụ role, id, is_admin).
g) Payload độc hại lưu trữ (stored XSS) đưa vào trường văn bản: <script>alert(1)</script>, <img src=x onerror=alert(1)>.
h) Nhồi kiểu dữ liệu: gửi array/object/null vào chỗ mong đợi string hoặc number.
i) Vượt giới hạn kích thước: chuỗi 10.000 ký tự, body JSON rất lớn.

Với mỗi test case, cột Expected phải nêu rõ HAI điều:
- Mã trạng thái kỳ vọng theo spec.
- Dấu hiệu nhận biết LỖ HỔNG nếu hệ thống trả về khác (ví dụ: 'Nếu trả 200 kèm dữ liệu → vi phạm SEC-02').

TỐI THIỂU 10 test case.
```

---

## P6 — Test case kiểm tra lược đồ response

```text
BƯỚC 6 — KIỂM TRA LƯỢC ĐỒ RESPONSE (Schema Validation).

Chỉ làm schema. 

Phần 6.1 — Viết JSON Schema (draft-07) cho response THÀNH CÔNG của API này, suy ra từ spec. Bắt buộc:
- Khai báo "type" chính xác cho từng trường (number khác string).
- Khai báo "required" cho mọi trường spec nói là luôn có.
- Đặt "additionalProperties": false, để phát hiện trường thừa không có trong spec.

Phần 6.2 — Viết JSON Schema cho response LỖI.

Phần 6.3 — Test case, dùng đúng bảng của Bước 3, TC_ID: TC-<APIID>-SCH-001, Nhóm: "Schema".
Phủ tối thiểu:
- Response khớp schema hoàn toàn.
- Kiểu dữ liệu của từng trường quan trọng (đặc biệt trường số: phải là number, KHÔNG được là string).
- Không có trường thừa ngoài spec.
- Không thiếu trường bắt buộc.
- Response lỗi cũng phải có cấu trúc nhất quán giữa các loại lỗi khác nhau.
- Content-Type là application/json.
- Tính nhất quán: gọi cùng endpoint với nhiều id khác nhau, kiểu dữ liệu của cùng một trường phải giống nhau ở mọi bản ghi.

TỐI THIỂU 6 test case.
```

---

## P7 — Hợp nhất, rà lỗ hổng, chốt ≥ 35 case

```text
BƯỚC 7 — HỢP NHẤT VÀ RÀ SOÁT ĐỘ PHỦ.

Phần 7.1 — Gộp toàn bộ test case từ Bước 3, 4, 5, 6 thành MỘT bảng duy nhất, đánh lại TC_ID liên tục TC-<APIID>-001 → TC-<APIID>-NNN, giữ nguyên cột "Nhóm" và cột truy vết.

Phần 7.2 — Bảng thống kê:
| Nhóm | Số test case | Tỷ lệ % |
với 4 nhóm Domain / State Transition / Security / Schema và dòng Tổng.
TỔNG BẮT BUỘC ≥ 35. Nếu chưa đủ, tự bổ sung ở nhóm còn mỏng và ghi rõ đã bổ sung những TC_ID nào.

Phần 7.3 — TỰ PHÊ BÌNH. Trả lời thẳng thắn, không tự khen:
1. Ba điểm yếu lớn nhất của bộ test case này là gì?
2. Loại lỗi nào bộ test này CHẮC CHẮN không phát hiện được? Vì sao?
3. Nếu chỉ được giữ lại 10 test case, bạn giữ TC nào và bỏ TC nào? Vì sao?
4. Có test case nào bạn viết dựa trên phỏng đoán chứ không dựa trên spec không? Liệt kê chính xác.

Phần 7.4 — Xuất bảng đã gộp ở Phần 7.1 dưới dạng khối mã CSV, phân tách bằng dấu phẩy, có dòng header, mọi ô có chứa dấu phẩy hoặc xuống dòng đều bọc trong dấu nháy kép. Đây là file tôi sẽ nhập vào Excel.
```

---

## P8 — Sinh Postman collection

```text
BƯỚC 8 — SINH POSTMAN COLLECTION.

Từ bảng hợp nhất ở Bước 7, sinh file JSON Postman Collection v2.1.0 hoàn chỉnh, tôi sẽ import trực tiếp.

Yêu cầu kỹ thuật:
- Tên collection: "EShop-HW06-<APIID>"; gom request vào folder theo Nhóm (Domain / State Transition / Security / Schema).
- Dùng biến: {{baseUrl}}, {{studentId}}, {{adminToken}}, {{userToken}}, {{productId}}. KHÔNG hard-code URL.
- Tên mỗi request đặt theo mẫu: "TC-xxx | <tiêu đề test>".
- Mỗi request có khối "event" chứa script test với pm.test(), assertion phải cụ thể: kiểm tra status, kiểm tra kiểu dữ liệu của trường, kiểm tra thông điệp lỗi, kiểm tra thời gian phản hồi < 2000ms.
- Các request phụ thuộc nhau (login lấy token, tạo tài nguyên lấy id) phải lưu giá trị bằng pm.collectionVariables.set() ở script test, và đặt đúng thứ tự.
- Với test case schema, dùng tv4 hoặc ajv có sẵn trong sandbox Postman để validate theo JSON Schema ở Bước 6.
- Ở test case bảo mật, KHÔNG assert theo hành vi sai hiện tại; assert theo hành vi ĐÚNG mà spec đòi hỏi, để test FAIL nếu hệ thống có lỗ hổng. Thêm comment giải thích trong script.

Xuất ra một khối mã JSON duy nhất, hợp lệ, không cắt ngắn, không kèm giải thích.
```

---

## P9 — File dữ liệu cho Collection Runner (data-driven)

```text
BƯỚC 9 — FILE DỮ LIỆU CHO DATA-DRIVEN RUN.

Chọn ra một request phù hợp nhất cho kiểm thử hướng dữ liệu trong API này (thường là request có nhiều biến thể tham số).

Sinh:
1. Một file CSV dữ liệu, header là tên biến Postman, mỗi dòng là một bộ dữ liệu, có cột expected_status và expected_message.
2. Script test tương ứng đọc biến bằng pm.iterationData.get(), assert theo expected_status và expected_message của từng dòng.
3. Câu lệnh Newman chạy data file này trên Windows PowerShell.

Tối thiểu 12 dòng dữ liệu, phủ cả hợp lệ lẫn không hợp lệ, và phải bao gồm ít nhất 3 dòng giá trị biên.
```

---

## PG — Thiết kế AI Test Generator (chạy 1 lần, cho mục Agent Skill 10đ)

```text
Thiết kế một CÔNG CỤ SINH TEST CASE API TỰ ĐỘNG dựa trên AI cho hệ thống EShop: đầu vào là tài liệu đặc tả API, đầu ra là bộ test case.

Tôi CHỈ cần phần pseudocode và mô tả thiết kế. TUYỆT ĐỐI KHÔNG vẽ sơ đồ, không xuất Mermaid, không vẽ ASCII art — phần sơ đồ tôi tự vẽ tay theo quy định của môn học.

Hãy trình bày:

1. Kiến trúc theo pipeline, liệt kê từng giai đoạn với: đầu vào, xử lý, đầu ra, và tiêu chí thoát của giai đoạn đó. Gợi ý các giai đoạn: Phân tích spec → Trích xuất tham số → Sinh phân vùng → Sinh test case theo 4 kỹ thuật → Khử trùng lặp → Kiểm tra độ phủ → Xuất Postman collection.
2. Cấu trúc dữ liệu trung gian: định nghĩa lược đồ JSON cho ApiEndpoint, Parameter, Partition, TestCase.
3. Pseudocode Python có chú thích, các hàm chính, thể hiện rõ vòng lặp phản hồi khi độ phủ chưa đạt ngưỡng.
4. Chiến lược prompt cho từng giai đoạn: prompt gửi cho LLM là gì, ràng buộc output ra sao, xử lý thế nào khi LLM trả về sai định dạng.
5. Cơ chế kiểm chứng: làm sao phát hiện LLM bịa endpoint hoặc bịa trường dữ liệu.
6. Cách đo độ phủ (coverage metric) và ngưỡng để dừng vòng lặp.
7. Liệt kê 5 hạn chế đã biết của thiết kế này.

Sau đó, mô tả các thành phần của sơ đồ bằng LỜI VĂN (danh sách khối và mũi tên nối) để tôi làm căn cứ tự vẽ.
```

---

# PHẦN B — API CONTEXT CARDS

> Dán nguyên khối tương ứng vào `{{API_CARD}}` ở prompt P0.

<details open>
<summary><b>API 1 — FR-06 · GET /api/products/:id</b> (APIID = <code>API1</code>)</summary>

```text
=== API 1 — FR-06: Xem chi tiết sản phẩm ===
Base URL: http://localhost:3000

ENDPOINT: GET /api/products/:id
- Tham số path: id (định danh sản phẩm)
- Không có request body
- Spec API không nói endpoint này cần xác thực

Trích api_specification.md:
"3.2 Xem chi tiết một sản phẩm — Endpoint: GET /api/products/:id"

Cấu trúc bản ghi sản phẩm (suy ra từ endpoint Thêm/Sửa sản phẩm trong spec):
{
  "name": "Tên sản phẩm",
  "price": 100000,
  "description": "Mô tả",
  "imageUrl": "http://...",
  "category_id": 1
}
Bản ghi trả về từ CSDL còn có trường "id".

Yêu cầu nghiệp vụ FR-06 (trích README của SUT):
- Hiển thị đầy đủ: Ảnh lớn, Tên, Giá, Mô tả, Danh mục.
- Có ô nhập Số lượng (chỉ nhận số nguyên dương, tối thiểu là 1).
- Nút Thêm vào giỏ hàng, sau khi bấm hiển thị phản hồi trực quan.

Endpoint liên quan để lấy dữ liệu thiết lập:
- GET /api/products  (danh sách sản phẩm, hỗ trợ ?search=keyword)
- GET /api/categories (danh sách danh mục)
- POST /api/cart  Body: {"id":1,"name":"Sản phẩm A","price":100000,"quantity":2}  — yêu cầu Bearer token

Yêu cầu bảo mật liên quan cần cân nhắc: SEC-02, SEC-04, SEC-05.
```

</details>

<details>
<summary><b>API 2 — FR-09 · POST /api/apply-coupon</b> (APIID = <code>API2</code>)</summary>

```text
=== API 2 — FR-09: Áp dụng mã giảm giá ===
Base URL: http://localhost:3000

ENDPOINT CHÍNH: POST /api/apply-coupon
Body (JSON):
{
  "code": "SAVE10",
  "total_amount": 500000,
  "user_id": 1
}
Mô tả theo spec: "Tính toán tổng tiền sau khi giảm. Trả về cấu trúc JSON chứa discount_amount và final_amount."

ENDPOINT LIÊN QUAN:
- GET /api/coupons  — danh sách mã, yêu cầu header Authorization: Bearer <token>
- POST /api/admin/coupons — tạo mã mới (yêu cầu quyền admin)
  Body: {"code":"TET2025","type":"percent","discount_value":15,"min_order_amount":200000,"expired_at":"2025-01-31","max_uses_per_user":1}
- DELETE /api/admin/coupons/:id — xóa mã (yêu cầu quyền admin)
- POST /api/login — lấy JWT

QUY TẮC NGHIỆP VỤ FR-09 — mã chỉ được áp dụng khi THỎA MÃN CẢ 5 ĐIỀU KIỆN:
C1  Mã tồn tại: mã phải có trong CSDL và đang hoạt động (is_active = 1)
C2  Còn hạn sử dụng: ngày hiện tại phải TRƯỚC expired_at
C3  Đủ ngưỡng đơn hàng: tổng đơn hàng >= (LỚN HƠN HOẶC BẰNG) min_order_amount
C4  Đã đăng nhập: người dùng phải có JWT Token hợp lệ
C5  Chưa dùng hết lượt: số lần user này đã dùng mã < max_uses_per_user

CÔNG THỨC TÍNH GIẢM GIÁ (theo spec):
- Loại percent: discount_amount = total × discount_value / 100
- Loại fixed:   discount_amount = discount_value
- final_amount = total − discount_amount

DỮ LIỆU MÃ GIẢM GIÁ CÓ SẴN TRONG HỆ THỐNG:
| Mã      | Loại    | Giá trị  | Ngưỡng tối thiểu | Hạn dùng   | Số lần/người |
| SAVE10  | percent | 10%      | 300000           | 2099-12-31 | 1            |
| BIGBUY  | fixed   | 50000    | 500000           | 2099-12-31 | 1            |
| VIP100  | fixed   | 100000   | 300000           | 2099-12-31 | 2            |
| EXPIRED | percent | 20%      | 100000           | 2020-01-01 | 1            |

Ghi trạng thái sử dụng mã: POST /api/coupon-usage với body {"coupon_id": <id>} — yêu cầu Bearer token.

Yêu cầu bảo mật liên quan cần cân nhắc: SEC-02, SEC-03, SEC-05, SEC-06.
```

</details>

<details>
<summary><b>API 3 — FR-15 · POST / PUT / DELETE /api/products</b> (APIID = <code>API3</code>)</summary>

```text
=== API 3 — FR-15: Quản lý sản phẩm (CRUD) dành cho Admin ===
Base URL: http://localhost:3000

CÁC ENDPOINT (theo spec, thuộc mục "Dành cho Admin"):
- Thêm sản phẩm:  POST   /api/products
- Cập nhật:       PUT    /api/products/:id
- Xóa:            DELETE /api/products/:id
- Đọc để đối chiếu: GET /api/products  và  GET /api/products/:id

Body khi Thêm/Sửa (JSON):
{
  "name": "Tên sản phẩm",
  "price": 100000,
  "description": "Mô tả",
  "imageUrl": "http://...",
  "category_id": 1
}

QUY TẮC NGHIỆP VỤ FR-15 (trích README của SUT):
- Admin có thể Thêm / Xem / Sửa / Xóa sản phẩm.
- Ràng buộc đầu vào:
  · Tên sản phẩm: BẮT BUỘC, tối đa 255 ký tự.
  · Giá: BẮT BUỘC, phải là số DƯƠNG (> 0).
  · Danh mục: BẮT BUỘC, phải chọn từ danh sách có sẵn.
- Khi Sửa một sản phẩm, CHỈ sản phẩm đó bị thay đổi — các sản phẩm khác giữ nguyên.

RÀNG BUỘC PHÂN QUYỀN:
Spec ghi rõ nhóm endpoint này "Dành cho Admin". Theo SEC-02 và SEC-03, chúng phải yêu cầu
JWT hợp lệ VÀ kiểm tra role = 'admin' trong token, không chỉ kiểm tra token có tồn tại.

ENDPOINT HỖ TRỢ:
- GET /api/categories — lấy category_id hợp lệ
- POST /api/login — lấy JWT của admin và của user thường
- POST /api/admin/import-products — import hàng loạt, body {"products":[{...}]}, yêu cầu token.
  Ràng buộc theo FR-16: name không rỗng, price là số dương, và NẾU CÓ LỖI Ở BẤT KỲ DÒNG NÀO
  THÌ TOÀN BỘ IMPORT PHẢI ROLLBACK (all-or-nothing).

Yêu cầu bảo mật liên quan cần cân nhắc: SEC-02, SEC-03, SEC-04, SEC-05.
```

</details>

---

# PHẦN C — MẪU PROMPT SỬA LỖI (tôi sẽ điền và đưa lại cho bạn)

```text
Bước <N> của bạn có các vấn đề sau. Hãy SỬA LẠI, không viết lại từ đầu những phần đã đúng.

<van_de>
1. <mô tả lỗi> — Bằng chứng: <trích spec / trích output>. Cách sửa: <yêu cầu cụ thể>.
2. ...
</van_de>

<bo_sung_bat_buoc>
- ...
</bo_sung_bat_buoc>

Xuất lại CHỈ những dòng/bảng bị thay đổi, kèm cột "Thay đổi gì" để tôi đối chiếu. Cuối cùng xuất lại bảng đầy đủ đã sửa.
```

---

# PHẦN D — TÔI SẼ AUDIT NHỮNG GÌ

Khi bạn dán output về, tôi kiểm tra theo thứ tự:

| # | Tiêu chí audit | Nhãn |
|---|----------------|------|
| 1 | Endpoint / trường dữ liệu có tồn tại thật trong spec không (chống bịa) | INVALID nếu bịa |
| 2 | Expected result lấy theo **spec** hay theo **hành vi thực tế** của SUT | INVALID nếu lấy theo hành vi sai |
| 3 | Assertion có kiểm chứng được không hay chung chung | INCOMPLETE |
| 4 | Biên có đủ min−1 / min / min+1 không | INCOMPLETE |
| 5 | Có phủ đủ 4 nhóm + ánh xạ SEC-01..07 không | INCOMPLETE |
| 6 | Có test case trùng lặp / khác tên cùng nội dung không | INVALID |
| 7 | Tiền điều kiện & dọn dẹp có khả thi khi chạy tự động không | INCOMPLETE |
| 8 | Số lượng có đạt ngưỡng của bước đó không | INCOMPLETE |

Nhãn dùng đúng 3 giá trị đề yêu cầu: **VALID / INVALID / INCOMPLETE**, kèm lý do — đây chính là nội dung bạn bê thẳng vào mục *Audit* của report.

---

# PHẦN E — GHI CHÉP AI AUDIT (làm ngay, đừng để cuối)

Mỗi lượt prompt, thêm 1 dòng vào `ai/AI_Audit_Report.md`:

```markdown
### Lượt <n> — <API> — Bước <P?>
- **Công cụ AI:** Claude (web)
- **Ngày giờ:** 2026-08-__ __:__ (GMT+7)
- **Mục đích:** <sinh phân vùng cho tham số id>
- **Prompt:** xem `ai/prompts/api1_p2_prompt.md`
- **Output:** xem `ai/prompts/api1_p2_output.md`
- **Kết quả audit:** VALID <n> / INVALID <n> / INCOMPLETE <n>
- **Hành động của tôi:** <sửa gì, vì sao>
```
