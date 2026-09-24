# API & Webhook Spec

สัญญาของ REST API ที่เว็บเรียก webhook ที่ระบบรับ และการเรียกระบบภายนอก สเปกที่เครื่องอ่านได้ (OpenAPI) สร้างจาก FastAPI ที่ `/api/v1/openapi.json` เอกสารนี้บอกกติกาและเจตนาที่ OpenAPI บอกไม่ได้ ถ้าสองอย่างขัดกัน ให้แก้โค้ดหรือเอกสารให้ตรงกันใน PR เดียวกัน

## กติกาทั่วไป

| เรื่อง | กติกา |
| --- | --- |
| Base path | `/api/v1` เปลี่ยน major version เมื่อมีการเปลี่ยนที่ทำให้ client เดิมพัง |
| รูปแบบ | JSON, ชื่อช่องเป็น `snake_case` |
| ID | UUID แบบ string |
| เวลา | ISO 8601 แบบ UTC เช่น `2026-10-15T03:20:00Z` |
| วันที่ในเอกสาร | `YYYY-MM-DD` แบบ ค.ศ. |
| เงิน | string ทศนิยม 2 ตำแหน่ง เช่น `"1070.00"` ห้ามส่งเป็น number |
| Pagination | `?limit=50&cursor=...` ตอบกลับ `{ "items": [...], "next_cursor": "..." }` limit สูงสุด 200 |
| Auth | session cookie (ดู `docs/SECURITY.md`) |
| CSRF | request ที่เปลี่ยนข้อมูลต้องส่ง header `X-CSRF-Token` |
| Idempotency | POST ที่สร้างข้อมูลรับ header `Idempotency-Key` ระบบจำผล 24 ชั่วโมง |
| Rate limit | ตอบ header `RateLimit-Limit`, `RateLimit-Remaining`, `RateLimit-Reset` เกินแล้วตอบ 429 พร้อม `Retry-After` |
| Request ID | ทุก response มี `X-Request-Id` |

### Error

ใช้ `application/problem+json` (RFC 9457)

```json
{
  "type": "https://docs.example/errors/document-not-ready",
  "title": "Document is not ready for export",
  "status": 409,
  "detail": "เอกสารนี้ยังมีสิ่งที่พบระดับวิกฤตที่ยังไม่ปิด",
  "code": "document_not_ready",
  "request_id": "01J..."
}
```

`code` เป็นค่าคงที่ที่หน้าเว็บใช้เลือกข้อความ ส่วน `detail` เป็นภาษาไทยสำหรับแสดงผล

| status | ใช้เมื่อ |
| --- | --- |
| 400 | รูปแบบคำขอผิด |
| 401 | ไม่มี session หรือ session หมดอายุ |
| 403 | มี session แต่ Role ไม่มีสิทธิ์ |
| 404 | ไม่พบ หรืออยู่ใน tenant อื่น (ห้ามตอบ 403 กับข้อมูลของ tenant อื่น) |
| 409 | state ไม่อนุญาต เช่นส่งออกเอกสารที่ยังไม่ Ready |
| 413 | ไฟล์ใหญ่เกิน |
| 415 | ชนิดไฟล์ไม่รองรับ |
| 422 | ข้อมูลผ่านรูปแบบแต่ผิดกฎทางธุรกิจ |
| 429 | เกิน rate limit หรือเกินโควตา |

## REST API เฟส 1

| Method | Path | Role | ทำอะไร |
| --- | --- | --- | --- |
| POST | `/auth/magic-link` | สาธารณะ | ส่งลิงก์เข้าระบบทางอีเมล |
| POST | `/auth/magic-link/verify` | สาธารณะ | แลก token เป็น session |
| POST | `/auth/line` | สาธารณะ | แลก LINE ID token เป็น session |
| POST | `/auth/logout` | ทุก Role | ออกจากระบบ |
| GET | `/me` | ทุก Role | ข้อมูล Member และ Firm ปัจจุบัน |
| GET, PATCH | `/firm` | `firm_owner` (PATCH) | ดูและแก้ข้อมูล Firm |
| GET, POST | `/firm/members` | `firm_owner` | ดูรายชื่อและเชิญ Member |
| PATCH, DELETE | `/firm/members/{member_id}` | `firm_owner` | เปลี่ยน Role หรือปิดสิทธิ์ |
| GET, POST | `/clients` | `firm_owner`, `firm_staff` | ดูรายการและเพิ่ม Client Company (POST ดึงชื่อที่อยู่จาก RD VAT Service) |
| GET, PATCH | `/clients/{client_id}` | `firm_owner`, `firm_staff` | ดูและแก้ Client Company |
| GET | `/clients/{client_id}/summary?tax_period=YYYY-MM` | `firm_owner`, `firm_staff` | ตัวเลขสรุปของเดือนภาษี |
| POST | `/clients/{client_id}/line-invites` | `firm_owner`, `firm_staff` | สร้างรหัสเชิญสำหรับเชื่อมกลุ่ม LINE |
| POST | `/clients/{client_id}/documents` | `firm_owner`, `firm_staff` | อัปโหลด Document (multipart) |
| POST | `/clients/{client_id}/document-requests` | `firm_owner`, `firm_staff` | ส่ง Document Request ไปที่ LINE ของลูกค้า |
| GET | `/documents` | `firm_owner`, `firm_staff` | ค้นหา กรองด้วย `client_id`, `tax_period`, `status`, `document_type`, `has_open_findings` |
| GET | `/documents/{document_id}` | `firm_owner`, `firm_staff` | รายละเอียด Document พร้อม Extraction ปัจจุบัน, Field และ Finding |
| GET | `/documents/{document_id}/file-url` | `firm_owner`, `firm_staff` | signed URL ของไฟล์ต้นฉบับ อายุ 5 นาที |
| PATCH | `/documents/{document_id}/fields` | `firm_owner`, `firm_staff` | แก้ Field (สร้าง Correction) |
| POST | `/documents/{document_id}/reprocess` | `firm_owner`, `firm_staff` | ประมวลผลใหม่ด้วย pipeline ล่าสุด |
| DELETE | `/documents/{document_id}` | `firm_owner` | soft delete |
| GET | `/findings` | `firm_owner`, `firm_staff` | ค้นหา Finding |
| POST | `/findings/{finding_id}/resolve` | `firm_owner`, `firm_staff` | ปิด Finding แบบ `accepted` หรือ `dismissed` พร้อมเหตุผล |
| GET | `/review-tasks` | `firm_owner`, `firm_staff` | Review Task ที่เปิดอยู่ |
| POST | `/review-tasks/{task_id}/claim` | `firm_owner`, `firm_staff` | รับงานตรวจ |
| POST | `/review-tasks/{task_id}/complete` | `firm_owner`, `firm_staff` | ปิดงานตรวจ |
| GET | `/clients/{client_id}/vendors` | `firm_owner`, `firm_staff` | รายชื่อ Vendor |
| POST | `/exports` | `firm_owner`, `firm_staff` | สร้าง Export ของ `client_id` + `tax_period` + `target` |
| GET | `/exports/{export_id}` | `firm_owner`, `firm_staff` | สถานะ Export |
| GET | `/exports/{export_id}/file-url` | `firm_owner`, `firm_staff` | signed URL ของไฟล์ส่งออก |
| POST | `/exports/{export_id}/cancel` | `firm_owner` | ยกเลิก Export (เอกสารกลับเป็น Ready) |
| POST | `/leakage-scans` | `platform_admin` (เฟส 1) | เริ่ม Leakage Scan |
| GET | `/leakage-scans/{scan_id}` | `firm_owner`, `platform_admin` | สถานะและรายงาน |
| GET | `/usage?period=YYYY-MM` | `firm_owner` | usage เทียบกับโควตา |
| GET | `/healthz`, `/readyz` | ระบบ | health check (นอก `/api/v1`) |

### ตัวอย่าง: รายละเอียด Document

`GET /api/v1/documents/{document_id}`

```json
{
  "id": "0192b7c4-...",
  "client_id": "0192b7a0-...",
  "status": "needs_review",
  "document_type": "tax_invoice_full",
  "source": "line",
  "tax_period": "2026-10",
  "received_at": "2026-10-15T03:20:00Z",
  "extraction": {
    "prompt_version": "extract-tax-invoice/v3",
    "overall_confidence": 0.91,
    "fields": [
      { "name": "seller_tax_id", "value": "0105551234567", "confidence": 0.99, "bbox": { "page": 1, "x": 0.12, "y": 0.08, "w": 0.2, "h": 0.02 } },
      { "name": "buyer_address", "value": null, "confidence": 0.0, "bbox": null }
    ],
    "line_items": [ { "line_no": 1, "description": "ค่าบริการทำความสะอาด", "quantity": "1", "unit_price": "1000.00", "amount": "1000.00" } ]
  },
  "findings": [
    { "id": "0192b7c9-...", "rule_id": "TAX-001", "severity": "critical", "result": "fail", "status": "open", "message_th": "ใบกำกับภาษีนี้ไม่มีที่อยู่ผู้ซื้อ อาจใช้เคลมภาษีซื้อไม่ได้", "amount_at_risk": "70.00", "evidence": { "missing_fields": ["buyer_address"] } }
  ],
  "review_tasks": [ { "id": "0192b7ca-...", "reason": "finding", "status": "open" } ]
}
```

### ตัวอย่าง: แก้ Field

`PATCH /api/v1/documents/{document_id}/fields`

```json
{ "changes": [ { "name": "buyer_address", "value": "99 ถนนสุขุมวิท แขวงคลองเตย เขตคลองเตย กรุงเทพฯ 10110" } ] }
```

ผล: ระบบสร้าง Correction, รัน Check ที่เกี่ยวกับช่องนั้นใหม่ แล้วตอบรายละเอียด Document ฉบับใหม่

### ตัวอย่าง: ปิด Finding

`POST /api/v1/findings/{finding_id}/resolve`

```json
{ "resolution": "dismissed", "reason": "ลูกค้าส่งใบกำกับภาษีฉบับแก้ไขมาแล้ว ดูเอกสาร 0192b7cf-..." }
```

`reason` บังคับ ความยาว 5–500 ตัวอักษร

## Webhook ขาเข้า

### LINE

`POST /webhooks/line`

1. ตรวจ header `x-line-signature` = Base64(HMAC-SHA256(channel secret, raw body)) เทียบแบบ constant-time ไม่ผ่านตอบ 401
2. ตัดเหตุการณ์ซ้ำด้วย `webhookEventId` (เก็บใน Redis 24 ชั่วโมง)
3. ตอบ 200 ทันที งานอื่นเข้า queue ทั้งหมด

| เหตุการณ์ | การทำงาน |
| --- | --- |
| `join` (บอทถูกเชิญเข้ากลุ่ม) | ตอบวิธีเชื่อมกลุ่มด้วยรหัสเชิญ |
| `message` ข้อความ `เชื่อมต่อ <รหัส>` | ตรวจรหัสเชิญ แล้วสร้าง `line_links` ของกลุ่มนั้น |
| `message` ชนิด `image` หรือ `file` | ถ้ากลุ่มเชื่อมแล้ว: reply รับเอกสาร, ดึงไฟล์จาก `GET https://api-data.line.me/v2/bot/message/{messageId}/content`, ส่งเข้า `ingest.receive_file()` ถ้ายังไม่เชื่อม: reply วิธีเชื่อมกลุ่ม |
| `message` ข้อความอื่น | ไม่ตอบ เพื่อไม่รบกวนการคุยในกลุ่ม |
| `leave` | ปิด `line_links` ของกลุ่มนั้น |

reply token ใช้ได้ครั้งเดียวและมีอายุสั้น ต้องใช้ตอนรับ webhook ข้อความที่ส่งทีหลังใช้ push ซึ่งนับโควตา

### Email ขาเข้า

`POST /webhooks/email/{provider}`

- ตรวจ signature ตามวิธีของผู้ให้บริการที่เลือก
- ที่อยู่ปลายทางมีรูปแบบ `<client-slug>.<token>@in.<domain>` ใช้ `token` หา Client Company
- รับเฉพาะไฟล์แนบที่ชนิดอนุญาตใน `docs/SECURITY.md` เนื้อหา email เก็บเป็นข้อมูลประกอบ ไม่ใช้เป็นคำสั่ง
- ผู้ส่งที่ไม่อยู่ในรายชื่อ Submitter ของ Client Company ถูกกักไว้ให้ Member อนุมัติก่อนประมวลผล

## การเรียกระบบภายนอก

| ระบบ | Adapter | วิธีเรียก | กติกา |
| --- | --- | --- | --- |
| LINE reply | `adapters.line` | `POST https://api.line.me/v2/bot/message/reply` | ใช้ทันทีระหว่างรับ webhook |
| LINE push | `adapters.line` | `POST https://api.line.me/v2/bot/message/push` | ใช้เฉพาะแจ้งผลที่ต้องให้ลูกค้าทำอะไร และ Document Request |
| RD VAT Service | `adapters.rd_vat` | SOAP `https://rdws.rd.go.th/serviceRD3/vatserviceRD3.asmx` (username และ password = `anonymous` ตามเอกสารกรมสรรพากร) | cache 30 วัน, ไม่เกิน 2 คำขอต่อวินาที, timeout 10 วินาที, ล้มเหลวแล้ว Check ได้ `unverified` |
| OCR | `adapters.ocr` | OpenAI-compatible API ของ Typhoon OCR | timeout 120 วินาทีต่อหน้า, retry 2 ครั้ง |
| LLM | `adapters.llm` | ตามผู้ให้บริการ | บันทึก `ai_calls` ทุกครั้ง, หยุดเมื่อถึงงบรายวันของ tenant |
| Object storage | `adapters.storage` | S3 API | ไฟล์ต้นฉบับเขียนครั้งเดียว |

## เหตุการณ์ภายใน

ชื่อเหตุการณ์ใช้ทั้งใน queue และ `audit_events.action`

| เหตุการณ์ | เกิดเมื่อ | ข้อมูลหลัก |
| --- | --- | --- |
| `document.received` | สร้าง Document | `document_id`, `source` |
| `document.duplicate` | พบไฟล์ซ้ำ | `document_id`, `original_document_id` |
| `document.extracted` | Extraction เสร็จ | `document_id`, `extraction_id`, `overall_confidence` |
| `document.checked` | Check ทั้งหมดรันเสร็จ | `document_id`, `finding_ids` |
| `document.ready` | ไม่มีงานค้าง | `document_id` |
| `document.rejected` | อ่านไม่ได้ | `document_id`, `reason` |
| `finding.resolved` | ปิด Finding | `finding_id`, `resolution`, `reason` |
| `field.corrected` | แก้ Field | `field_id`, `old_value`, `new_value` |
| `export.created` | สร้างไฟล์ส่งออกเสร็จ | `export_id`, `document_count` |
| `leakage_scan.finished` | รายงานพร้อม | `scan_id`, `total_amount_at_risk` |

## Webhook ขาออก (เฟส 4, สำรองรูปแบบไว้)

ส่งเหตุการณ์ข้างบนให้พาร์ทเนอร์ แนบ header `X-Backoffice-Signature` = HMAC-SHA256 ของ body ด้วย secret ของพาร์ทเนอร์ และ `X-Backoffice-Event-Id` retry แบบ exponential backoff สูงสุด 24 ชั่วโมง
