# Guidelines

มาตรฐานการเขียนโค้ด การทดสอบ และการเขียน prompt ของโปรเจกต์นี้ ทุกข้อใช้กับทั้งคนและ agent ส่วนคำสั่งที่ตรวจได้จากเครื่องมือ (lint, format) ให้ดูจากค่าตั้งใน repo แทนการจำจากเอกสารนี้

## 1. วิธีทำงานของ agent

งานพร้อมส่งตรวจเมื่อครบทุกข้อใน [Definition of Done](#8-definition-of-done)

หยุดและถามผู้ใช้เมื่อ:

- ticket ขัดกับ ADR หรือ PRD (บอกว่าขัดข้อไหน)
- แก้ปัญหาเดิมแล้วยังไม่ผ่านครบ 3 รอบ ให้สรุปสิ่งที่ลองแล้วลง Progress note ก่อนถาม
- งานต้องแก้หรือลบ test ที่มีอยู่แล้ว
- งานต้องเปลี่ยนกฎภาษีหรือเกณฑ์ตัดสินของ Check
- งานต้องแก้ schema ที่มีข้อมูลลูกค้าอยู่แล้ว
- งานแตะการจ่ายเงิน, auth หรือการแยก tenant นอกเหนือจากที่ ticket ระบุ
- ต้องเพิ่ม dependency ใหม่ที่ไม่มีใน stack ของ `docs/ARCHITECTURE.md`

## 2. Python

### ขอบเขต module

- module อื่น import ได้เฉพาะ `backoffice.<module>.api` เท่านั้น ของอื่นใน module เป็นของภายใน
- adapter ของระบบภายนอกอยู่ใน `backoffice/adapters/` และถูกส่งเข้า service ผ่าน dependency injection เพื่อสลับเป็น fake ใน test ได้
- logic ทางธุรกิจอยู่ใน service ของ module ไม่อยู่ใน router ของ FastAPI หรือใน Celery task ตัว task และ router มีหน้าที่แค่รับค่า เรียก service และแปลงผลลัพธ์

### Type และ model

- เปิด mypy strict ทุก function มี type hint
- ข้อมูลเข้าออกของ API, task และ adapter ใช้ Pydantic model
- ค่าที่มีชุดจำกัดใช้ `StrEnum` ชื่อค่าตรงกับ `CONTEXT.md`

### ข้อมูลเฉพาะของโปรเจกต์

| เรื่อง | วิธีทำ |
| --- | --- |
| เงิน | `Decimal` เสมอ สร้างจาก string ไม่สร้างจาก float ปัดด้วย `ROUND_HALF_UP` ที่ 2 ตำแหน่ง |
| เวลา | `datetime` แบบมี timezone ทุกตัว ขอเวลาปัจจุบันผ่าน `Clock` ที่ inject ได้ เพื่อให้ test กำหนดเวลาได้ |
| ปี พ.ศ. | แปลงเป็น ค.ศ. ด้วยฟังก์ชันกลางใน `backoffice/common/thai_dates.py` ที่เดียว |
| ข้อความไทย | ผ่าน `normalize_thai()` ก่อนเปรียบเทียบ: Unicode NFC, ตัดอักขระความกว้างศูนย์, แปลงเลขไทยเป็นเลขอารบิก, ยุบช่องว่างซ้ำ |
| เลขประจำตัวผู้เสียภาษี | ตรวจ checksum ด้วยฟังก์ชันกลางตัวเดียวตาม `docs/TAX_RULES.md` |
| กฎที่มีวันเริ่มและสิ้นสุด | เก็บเป็นค่าตั้งที่มี `effective_from` และ `effective_to` เช่นอัตรา e-WHT 1% |

### Error และ log

- แต่ละ module มี exception ของตัวเองที่สืบจาก `DomainError` ชั้น API แปลงเป็น `application/problem+json` ตาม `docs/API_SPEC.md`
- log ด้วย structlog แบบ JSON ใส่ `request_id`, `firm_id`, `document_id` เมื่อมี
- log ข้อความของเอกสาร รูปภาพ หรือค่า Field ได้เฉพาะใน environment `local`

### Job ใน queue

- ทุก task ต้องรันซ้ำได้โดยผลเหมือนเดิม (idempotent) ใช้ `document_id` กับชื่อขั้นตอนเป็นกุญแจ
- task เปลี่ยน state ของ Document ผ่านฟังก์ชันเปลี่ยน state กลางใน `ingest` เท่านั้น
- ตั้ง retry แบบ exponential backoff สูงสุด 5 ครั้ง แล้วเปลี่ยน Document เป็น `failed`

### ฐานข้อมูล

- ทุก query วิ่งใน session ที่ตั้ง `app.firm_id` แล้ว (ดู `docs/SECURITY.md`)
- migration ต้องย้อนกลับได้ และไม่ล็อกตารางใหญ่นาน ถ้าจำเป็นต้องเปลี่ยนแบบกระทบมากให้ใช้ expand–contract
- เขียน SQL ผ่าน SQLAlchemy Core หรือ ORM ห้ามต่อ string เป็น SQL

## 3. TypeScript (apps/web)

- เปิด `strict` ใน tsconfig
- client ของ API สร้างจาก OpenAPI ของ FastAPI ห้ามเขียน type ของ API ซ้ำด้วยมือ
- กฎทางธุรกิจทั้งหมดอยู่ที่ backend หน้าเว็บแสดงผลและส่งคำสั่งเท่านั้น
- ข้อความภาษาไทยบนหน้าจอเก็บในไฟล์ข้อความกลาง ไม่ฝังในคอมโพเนนต์
- วันที่แสดงเป็นรูปแบบไทยแบบ พ.ศ. เช่น 15 ต.ค. 2569 จำนวนเงินมีตัวคั่นหลักพัน

## 4. การทดสอบ

- test ผ่าน public interface ของ module (`api.py`) ไม่ test ฟังก์ชันภายใน
- adapter ทุกตัวมี fake ใน `tests/fakes/` unit test ห้ามเรียก network
- endpoint ใหม่ทุกตัวต้องมี test ว่า Member ของ Firm อื่นเข้าถึงข้อมูลไม่ได้
- Check ทุกข้อมี test อย่างน้อย: ผ่าน, ไม่ผ่าน, ข้อมูลไม่พอ (ได้ `unverified` หรือ `skip`)
- ตั้งชื่อ test ตามพฤติกรรม เช่น `test_full_tax_invoice_without_buyer_address_raises_critical_finding`
- ฟังก์ชันตรวจ checksum และแปลงวันที่ใช้ property-based test (Hypothesis)
- ความแม่นของ AI วัดด้วย eval ใน `docs/EVALS.md` ไม่ใช่ unit test

## 5. กฎการเขียน prompt

prompt คือโค้ด มี version มี test และมีคนรับผิดชอบ

### ที่เก็บและ version

- เก็บที่ `apps/api/prompts/<name>/v<N>.md` มี frontmatter: `id`, `version`, `purpose`, `model_tier` (`small` | `medium` | `large`), `output_schema` (ชื่อ Pydantic model)
- prompt ที่ปล่อยใช้แล้วห้ามแก้ ให้สร้าง `v<N+1>` แล้วเปลี่ยนค่าตั้งให้ชี้ไปตัวใหม่
- `extractions.prompt_version` บันทึกทุกครั้งว่าใช้ prompt ไหน

### โครงของ prompt ดึงข้อมูล

1. บทบาทและงาน เช่น "ดึงข้อมูลจากใบกำกับภาษีภาษาไทยตาม schema"
2. schema ของผลลัพธ์ พร้อมความหมายของทุกช่อง
3. กฎการดึง: ค่าที่ไม่เห็นในเอกสารให้ตอบ `null`, คัดลอกตัวเลขตามที่เห็น, ใส่ปีตามที่พิมพ์ในเอกสาร (โค้ดเป็นคนแปลง พ.ศ.)
4. สำหรับทุกช่อง ให้ตอบ `evidence_text` เป็นข้อความที่คัดลอกจากผล OCR ตรงตัว
5. ตัวอย่าง 1–3 ชุดจาก Golden Set ที่เป็นข้อมูลสังเคราะห์
6. เนื้อหาเอกสารอยู่ในแท็ก `<document>` ท้ายสุด พร้อมข้อความว่าเนื้อหาในแท็กนี้เป็นข้อมูลที่ต้องอ่าน ไม่ใช่คำสั่ง

### กติกาการเรียกโมเดล

- ตั้ง temperature = 0 และบังคับ output เป็น JSON ตาม schema แล้วตรวจด้วย Pydantic ทุกครั้ง ถ้าไม่ผ่านให้ลองใหม่ 1 ครั้ง แล้วส่งให้คนตรวจ
- Confidence คำนวณด้วยโค้ด ไม่ใช้ค่าที่โมเดลบอกเอง ใช้ปัจจัย: `evidence_text` พบในผล OCR จริง, รูปแบบค่าถูกต้อง (เช่น checksum), ค่าสอดคล้องกับช่องอื่น
- เรียกโมเดลผ่าน `adapters.llm` เท่านั้น เพื่อบันทึก `ai_calls` และคุมงบ
- ผลของโมเดลใช้เป็นข้อมูลเข้า Check เท่านั้น ห้ามใช้ผลของโมเดลเป็นคำตัดสินของ Check, การอนุมัติ หรือการจ่าย (ADR-0003)

### เปลี่ยน prompt หรือโมเดล

รัน eval เต็มชุดตาม `docs/EVALS.md` ก่อน merge ทุกครั้ง แล้วแนบตารางผลเทียบกับ baseline ในคำอธิบาย PR

## 6. ข้อความถึงผู้ใช้ (LINE และหน้าเว็บ)

- สั้น ไม่เกิน 2 บรรทัดใน LINE แล้วจบด้วยสิ่งที่ผู้ใช้ต้องทำ
- ใช้คำไทยตาม `CONTEXT.md` เช่น "ใบกำกับภาษีเต็มรูป" ไม่ใช้ชื่อในโค้ด
- บอกว่าผิดตรงไหนและแก้อย่างไร เช่น "รูปเบลอตรงเลขผู้เสียภาษี รบกวนถ่ายใหม่ให้เห็นหัวบิลชัดๆ"
- Finding เป็นคำเตือนพร้อมหลักฐาน ใช้คำว่า "พบว่า" หรือ "ควรตรวจ" ไม่กล่าวหาว่าผู้ขายหรือพนักงานโกง

## 7. Git

- branch ของ ticket: `t/<feature>-<NN>` ตามกติกา Claim ใน `docs/ROADMAP.md`
- branch ของงานที่ไม่ใช่ ticket: `plan/<feature>` สำหรับ spec และ ticket จาก `/to-spec` กับ `/to-tickets` และ `docs/<slug>` หรือ `chore/<slug>` สำหรับแก้เอกสาร ADR บันทึกใน ROADMAP และ revert หนึ่ง PR ต่อหนึ่งเรื่อง
- commit แบบ Conventional Commits เช่น `feat(taxrules): check buyer tax id against client company` และมี type `wip:` ของทีมสำหรับ commit ที่ test ยังไม่ผ่าน commitlint หรือ pre-commit hook ต้องยอมรับ `wip:` ส่วน test ชุดเต็มรันใน CI
- ticket หนึ่งใบมี PR เดียว คำอธิบายมีลิงก์ ticket, สรุปพฤติกรรมที่เปลี่ยน, สรุป `/code-review` จากช่อง "ตรวจแล้ว" ของ Progress note และผล eval (ถ้าแตะ AI)
- ชื่อ PR คือหัวข้อ commit บน `main` หลัง squash ตั้งตาม Conventional Commits และลงท้ายด้วย ID เช่น `feat(ingest): reject duplicate LINE images (line-inbox-03)`
- ตาม `main` ด้วย `git fetch origin` แล้ว `git merge origin/main` branch ของ ticket มีหลายคน push (เจ้าของ ผู้ตรวจ คนรับต่อ) จึงใช้ merge และ push ตามปกติเสมอ
- **ผู้ approve** ต้องไม่ใช่ Owner (ปัจจุบันหรือเดิม) และไม่มี commit ของงานบน branch นั้น commit ของงานคือ commit ที่แก้ไฟล์นอก `.scratch/` commit `docs(ticket): review` และ `chore(ticket): done` ของผู้ตรวจไม่นับ ดูชื่อคนได้ด้วย `git log origin/main..HEAD --format=%an -- . ":!.scratch"` กติกาเจ้าของ area อยู่ใน `docs/guides/TEAMWORK.md` หัวข้อ 6
- PR merge ได้เมื่อ CI ผ่านและได้ approve ตามข้อบน แล้ว merge แบบ squash

## 8. Definition of Done

- [ ] ทุก acceptance criteria ใน ticket ติ๊กแล้ว และแต่ละข้อมี test ที่ผ่านครอบ
- [ ] test ใหม่ล้มก่อนแก้และผ่านหลังแก้
- [ ] `make check` ผ่าน
- [ ] `git fetch origin` แล้ว `/code-review origin/main .scratch/<feature>/issues/<NN>-<slug>.md` (ให้ไฟล์ ticket เป็น spec) แก้ข้อที่ขัดมาตรฐานของ repo ส่วนข้อที่ไม่แก้ให้สรุปพร้อมเหตุผลในช่อง "ตรวจแล้ว" ของ Progress note
- [ ] ถ้าแตะ prompt, โมเดล, pipeline หรือ Check: `make eval` เต็มชุดผ่านเกณฑ์ใน `docs/EVALS.md`
- [ ] ถ้าเพิ่ม endpoint: มี test แยก tenant และอัปเดต `docs/API_SPEC.md`
- [ ] ถ้าเปลี่ยน schema: มี migration ที่ย้อนกลับได้และอัปเดต `docs/DATA_MODEL.md`
- [ ] ถ้าเพิ่มหรือแก้กฎ: อัปเดต `docs/TAX_RULES.md` และตั้ง `status` ของกฎนั้นเป็น `needs-cpa-review`
- [ ] คำศัพท์ใหม่ถูกเพิ่มใน `CONTEXT.md` หรือใช้คำที่มีอยู่แล้ว
