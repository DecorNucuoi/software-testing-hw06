# HW06 – API Testing — CHECKLIST DELIVERABLES

> SUT: EShop (`D:\eshop-sut_1\eshop-sut`) · Runner: Postman + Newman · AI gen: Claude
> Thư mục bài nộp: `D:\HW06` (đây sẽ là git repo push lên GitHub)

---

## 0. API đã chốt (khớp FR bạn chọn ở các bài trước)

| # | Pool | FR | Tên | Endpoint chính | Endpoint phụ (setup/teardown) |
|---|------|-----|-----|----------------|-------------------------------|
| API 1 | A | **FR-06** | Xem chi tiết sản phẩm | `GET /api/products/:id` | `GET /api/products` |
| API 2 | B | **FR-09** | Mã giảm giá | `POST /api/apply-coupon` | `GET /api/coupons`, `POST /api/admin/coupons`, `POST /api/login` |
| API 3 | C | **FR-15** | Quản lý sản phẩm (CRUD) | `POST/PUT/DELETE /api/products` | `GET /api/categories`, `POST /api/login` |

✅ Đúng yêu cầu "mỗi pool 1 API". FR Mobile Login (Pool D) **không dùng** ở HW06 — đề nói rõ Pool D bị loại.

⚠️ Lưu ý: bảng self-assessment cũ của bạn ghi 25/25/25/15/10. Rubric HW06 là **30/30/30/10**. Phải sửa lại bảng trong `README.md`.

---

## 1. Rubric → việc phải làm

| Mục | Điểm | Phải có |
|-----|------|---------|
| API 1 — full pipeline | 30 | generate + audit + extend + execute + bugs |
| API 2 — full pipeline | 30 | như trên |
| API 3 — full pipeline | 30 | như trên |
| Agent Skill (AI test generator) | 10 | diagram tự vẽ + pseudocode (+ video demo = điểm cộng) |

**Full pipeline cho MỖI API** = 5 bước:

1. **Generate** — dùng AI sinh **≥ 35 test case/API**, bắt buộc phủ 4 nhóm:
   - `domain partitions` (ECP + BVA trên **mọi** tham số)
   - `state transitions` (FR-10: pending→confirmed→shipping→delivered + rule hủy đơn)
   - `security` (SEC-01…SEC-07: SQLi, IDOR, role escalation)
   - `schema validation` (response shape khớp spec 100%)
2. **Audit** — gán nhãn từng TC: `VALID` / `INVALID` / `INCOMPLETE` + lý do, và **sửa** cái sai.
3. **Extend** — tự thêm **≥ 5 TC** AI bỏ sót (ưu tiên security & state transition) + giải thích **vì sao** AI miss (prompt kém / giới hạn model / đặc thù API).
4. **Execute** — chạy Postman + Newman. **Mọi request phải có header `X-Student-Id: 23127362`** (dùng pre-request script ở collection level). Xuất Newman HTML report.
5. **Bugs** — báo bug thật (kể cả bug AI miss) vào **cả** report Markdown **và** GitHub Issues, mỗi issue kèm screenshot.

**Tổng tối thiểu:** 3 × (35 + 5) = **120 test case**.

---

## 2. Yêu cầu kỹ thuật xuyên suốt

- [ ] **Dùng càng nhiều tính năng Postman càng tốt** và **liệt kê ra trong report**:
      workspace · collection (có folder) · collection variables · environment · pre-request script ·
      test script · Collection Runner + **data file (CSV/JSON)** · monitor · mock server ·
      (bonus: examples, documentation, visualizer, `pm.collectionVariables`, chained requests)
- [ ] **CI/CD**: chạy Newman trong **GitHub Actions** trên repo của bạn
  - [ ] file workflow `.github/workflows/newman.yml`
  - [ ] **commit mẫu 1**: pipeline run **PASS toàn bộ**  → link + screenshot
  - [ ] **commit mẫu 2**: pipeline run **FAIL đúng 1 test case** → link + screenshot
  - [ ] **CI/CD report ngắn** mô tả cấu hình pipeline + 2 lần chạy
- [ ] **Git commit log**: commit riêng cho **từng bước** (generate / audit / extend / execute) × từng API → xuất ra file text
- [ ] **Anti-cheat evidence** (TA sẽ soi, KHÔNG được fake):
  - [ ] screenshot Postman Console thấy header `X-Student-Id: 23127362`
  - [ ] Newman output có hostname `localhost` / `127.0.0.1`
  - [ ] diagram test-generator **tự vẽ tay/tự dựng**, không phải AI xuất ra

---

## 3. Danh sách file phải nộp (`23127362_HW06_AI_API_{Điểm}.zip`)

Ví dụ tên file: `23127362_HW06_AI_API_090.zip`

```
D:\HW06\
├─ README.md                        ← bảng self-assessment (30/30/30/10) + test summary
├─ report/
│   ├─ HW06_report.md               ← BÁO CÁO CHÍNH (bắt buộc)
│   └─ HW06_report.pdf              ← bản PDF của file trên (bắt buộc)
├─ postman/
│   ├─ EShop_HW06.postman_collection.json
│   ├─ EShop_HW06.postman_environment.json
│   ├─ data/  (CSV/JSON cho data-driven run)
│   └─ postman_features_used.md
├─ newman/
│   ├─ newman-report-api1.html
│   ├─ newman-report-api2.html
│   ├─ newman-report-api3.html
│   └─ newman-report-full.html
├─ testcases/
│   ├─ HW06_testcases.xlsx          ← Excel test case (bắt buộc)
│   └─ test_summary.md
├─ ai/
│   ├─ AI_Audit_Report.md + .pdf    ← BẮT BUỘC: tool, ngày giờ, prompt, output từng lượt
│   ├─ AI_Critique.md + .pdf        ← BẮT BUỘC: 200–300 từ
│   └─ prompts/  (log thô từng prompt: p1.md, p1_output.md, ...)
├─ generator/
│   ├─ test_generator_diagram.png   ← TỰ VẼ (draw.io / Excalidraw / vẽ tay chụp ảnh)
│   ├─ test_generator_design.md     ← mô tả thiết kế
│   └─ test_generator.py            ← pseudocode / implement
│   └─ (bonus) SKILL.md             ← Agent Skill tái sử dụng + link YouTube demo
├─ cicd/
│   ├─ cicd_report.md
│   └─ screenshots/  (run-pass.png, run-fail.png)
├─ bugs/
│   ├─ bug_report.md                ← + link tới GitHub Issues
│   └─ screenshots/
├─ evidence/
│   └─ postman_console_student_id.png
├─ openapi/ (tùy chọn, +điểm)
│   └─ eshop_openapi.yaml           ← nếu AI gen thì phải audit luôn
├─ .github/workflows/newman.yml
└─ git_commit_log.txt
```

**Cảnh báo từ đề:** *thiếu bất kỳ tài liệu bắt buộc nào = 0 điểm.* Nộp trễ không được chấp nhận. Copy prompt của bạn khác = 0 cả hai.

---

## 4. Thứ tự thi công đề xuất (10 giờ)

| Giai đoạn | Việc | Ước lượng |
|-----------|------|-----------|
| G0 | Cài Postman/Newman, chạy backend, tạo repo, git init | 45' |
| G1 | Chạy prompt P0→P7 cho **API 1 (FR-06)** — tôi audit từng output | 1h30 |
| G2 | Audit + Extend API 1, dựng collection, chạy Newman, commit | 1h |
| G3 | API 2 (FR-09) — lặp lại | 1h45 |
| G4 | API 3 (FR-15) — lặp lại | 1h45 |
| G5 | CI/CD: workflow + 2 commit mẫu (pass / fail) | 45' |
| G6 | Agent Skill: diagram tự vẽ + pseudocode | 45' |
| G7 | Bug report + GitHub Issues + screenshots | 45' |
| G8 | Report chính + AI Audit + AI Critique + Excel + PDF + zip | 1h30 |

---

## 5. Quy tắc làm việc giữa bạn và tôi

1. Bạn copy prompt (mục P*) → dán sang **Claude web** → lấy output.
2. Dán output về đây → **tôi audit**: chỉ ra chỗ sai / thiếu / bịa, đối chiếu spec.
3. Tôi đưa **prompt sửa** (Pn-FIX) để bạn yêu cầu AI kia làm lại.
4. Lặp đến khi output đạt → sang bước tiếp theo.
5. **Bạn lưu lại mọi cặp prompt/output** vào `ai/prompts/` ngay lúc làm — đây là nguyên liệu cho AI Audit Report, làm sau sẽ mất.
