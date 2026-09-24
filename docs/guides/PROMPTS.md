# คู่มือการ prompt

prompt ที่คนพิมพ์สั่ง AI coding agent ระหว่างทำโปรเจกต์นี้ แบ่งเป็นหลักการเขียน และแม่แบบที่คัดลอกไปใช้ได้เลย ส่วนกฎการเขียน prompt ของ LLM ที่อยู่ในผลิตภัณฑ์ (prompt ดึงข้อมูลจากเอกสาร) อยู่ใน [`../GUIDELINES.md`](../GUIDELINES.md) หัวข้อ 5

วงจรว่าเมื่อไรใช้แม่แบบไหนอยู่ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md)

## 1. หลักการเขียน prompt

| หลัก | แบบที่ได้ผลน้อย | แบบที่ได้ผล |
| --- | --- | --- |
| **ชี้ ticket ทุกครั้ง** agent ใน session ใหม่จำอะไรไม่ได้ | "ทำเรื่องกันไฟล์ซ้ำต่อ" | "ทำต่อ ticket `@.scratch/line-inbox/issues/03-dedupe.md`" |
| **บอกเกณฑ์เสร็จที่ตรวจได้** | "ทำให้เสร็จ" | "เสร็จเมื่อ acceptance criteria ครบและ `make check` ผ่าน" |
| **กำหนดขอบเขต** | "ปรับปรุงระบบรับเอกสาร" | "แก้ได้เฉพาะ module `ingest` และ test ของมัน" |
| **ให้วางแผนก่อนเมื่องานแตะหลายไฟล์** | "เพิ่ม endpoint ใหม่เลย" | "เสนอแผนก่อน: พฤติกรรมตามลำดับ, seam ที่จะ test, ไฟล์ที่จะแตะ แล้วรอฉันยืนยัน" |
| **ชี้ไฟล์ แทนการแปะเนื้อหายาว** | แปะ log 2,000 บรรทัด | "error อยู่ใน `@logs/worker.log` ดู 50 บรรทัดสุดท้าย" หรือแปะเฉพาะ stack trace |
| **หนึ่ง prompt หนึ่งเรื่อง** | "แก้บั๊กนี้ refactor ไฟล์นั้น แล้วเพิ่ม feature ใหม่ด้วย" | แยกเป็น 3 ticket หรือ 3 prompt ต่อกัน |
| **ใช้คำจาก `CONTEXT.md`** | "บิล", "ใบเสร็จ", "เอกสาร" ปนกัน | "Document ประเภท `tax_invoice_full`" |
| **คง test ไว้** | "ทำให้ test ผ่าน" | "แก้โค้ดจน test ผ่าน โดยคง test เดิมไว้ ถ้าคิดว่า test ผิดให้บอกฉันก่อน" |
| **ดึงกลับทันทีที่ออกนอกทาง** | รอให้ทำจบแล้วค่อยบอก | กด Esc หยุด แล้วบอกทางที่ถูกทันที |
| **ถามเหตุผลเมื่อสงสัย** | ยอมรับโค้ดที่ไม่เข้าใจ | "อธิบายว่าทำไมเลือกแบบนี้ และทางเลือกอื่นคืออะไร ก่อนแก้ต่อ" |

พิมพ์ภาษาไทยได้ agent เข้าใจ แต่ชื่อไฟล์ ชื่อฟังก์ชัน ชื่อสถานะ และคำสั่งให้พิมพ์ตามตัวสะกดจริง

## 2. แม่แบบ

ส่วนที่อยู่ใน `<...>` ให้แทนด้วยค่าจริง `@` คือการใส่ไฟล์เข้า context ของ agent ใน Claude Code (รายละเอียดใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 3 ส่วนเครื่องมืออื่นอยู่ในหัวข้อ 8)

### P1 เริ่ม ticket ใหม่

ใช้เมื่อ: claim ticket แล้วตาม `docs/ROADMAP.md` (อยู่บน branch `t/<feature>-<NN>`) และเปิด session ใหม่ P1 คือ `/implement` แบบของทีม: เพิ่มขั้นเสนอแผนและยืนยัน seam ก่อน และ commit ทุกพฤติกรรมตาม `CLAUDE.md`

```text
ทำ ticket ของ branch นี้ ตามขั้น "เริ่มหรือทำต่อ" และ "วางแผน" ใน CLAUDE.md
อ่านเอกสารที่ CLAUDE.md บอกว่าต้องเปิดสำหรับงานแบบนี้
แล้วเสนอแผน: พฤติกรรมที่จะทำตามลำดับ, seam ที่จะเขียน test, ไฟล์ที่คาดว่าจะแตะ
รอฉันยืนยันแผนก่อนเริ่ม /tdd
```

### P2 ทำต่อ

ใช้เมื่อ: กลับมาวันใหม่, โควตารีเซ็ตแล้ว, หรือรับงานต่อจากเพื่อน ก่อนส่งให้อยู่บน branch ของ ticket แล้ว (`git switch t/<feature>-<NN>` และ `git pull --ff-only`) และ `/clear` หรือเปิด session ใหม่ ไม่ต้องพิมพ์ path ของ ticket เพราะ agent หาจากชื่อ branch

```text
ทำต่อ ticket ของ branch นี้ ตามขั้น "เริ่มหรือทำต่อ" ใน CLAUDE.md ใช้ seam ตาม Progress note
สรุปให้ฉัน: เสร็จอะไรแล้ว, อะไรค้าง, test ไหนล้ม, มีไฟล์ไหนแก้ค้างไม่ได้ commit, จะทำอะไรเป็นอย่างแรก
รอฉันตอบว่า "ไป" ก่อนแก้ไฟล์
```

ถ้ารับงานต่อจากเพื่อน ให้ทำขั้น "ส่งต่อให้คนอื่น" ใน `docs/ROADMAP.md` ก่อน

### P3 ทำต่อใน session เดิม

ใช้เฉพาะเมื่อ session เดิมยังสั้น (เพิ่งเริ่มไม่นานก่อนโควตาหมด) ปกติให้ `/clear` แล้วใช้ P2 เพราะ ticket กับ git มีทุกอย่างที่ต้องใช้แล้ว และการพิมพ์ต่อใน session ยาวจะส่ง context เก่าทั้งหมดไปใหม่

```text
ทำต่อจากที่ค้าง ทำตามขั้น "เริ่มหรือทำต่อ" ใน CLAUDE.md แล้วรัน test ที่ล้มอยู่
บอกฉันว่าจะทำต่อจากตรงไหน แล้วรอฉันตอบว่า "ไป"
```

### P4 บันทึกงาน

ใช้เมื่อ: จะเลิกงาน, `/usage` แสดงว่าใช้รอบ 5 ชั่วโมงไปเกิน 80%, ก่อน `/clear` ทั้งที่ ticket ยังไม่เสร็จ หรือจะส่งงานให้เพื่อน

```text
บันทึกงาน
```

`CLAUDE.md` กำหนดไว้แล้วว่าคำนี้ต้องทำอะไร (เขียน Progress note แล้ว commit ไฟล์ของงานบน branch ของ ticket) หลังจากนั้นคนเป็นผู้ push

```bash
git push
```

### P5 สำรวจหรือถามโดยไม่แก้ไฟล์

ใช้เมื่อ: อยากเข้าใจโค้ดก่อนตัดสินใจ ใช้คู่กับ plan mode

```text
ยังไม่ต้องแก้ไฟล์
อธิบายว่า <พฤติกรรม เช่น Document เปลี่ยนจาก checking เป็น needs_review> เกิดที่ไหนในโค้ด
ตอบเป็นลำดับขั้น พร้อมชื่อไฟล์และฟังก์ชัน และบอกจุดที่คิดว่าเสี่ยง
```

### P6 แก้บั๊ก

ถ้ายังไม่มี ticket ของบั๊กนี้ ให้สร้างใบใหม่ใน `.scratch/bugs/issues/` ระบุอาการและ seam ที่จะ test ในไฟล์ ticket แล้วเข้า `main` ผ่าน PR เล็กบน branch `docs/<slug>` ก่อน claim ถ้าด่วน ให้สร้างไฟล์ ticket บน branch `t/bugs-<NN>` แล้ว claim ในตัวเลย

```text
/diagnosing-bugs
ticket ของ branch นี้ (ทำขั้น "เริ่มหรือทำต่อ" ใน CLAUDE.md ก่อน)
อาการ: <สิ่งที่เห็น>
ที่ควรเป็น: <สิ่งที่คาดหวัง>
ทำซ้ำได้โดย: <ขั้นตอนหรือคำสั่ง>
error: <stack trace หรือ path ของไฟล์ log>
ทำ test หรือคำสั่งที่ล้มบนบั๊กนี้ให้ได้ก่อน แล้วค่อยแก้
```

### P7 แก้ตามความเห็นผู้ตรวจ

ผู้ตรวจ push ความเห็นขึ้น branch ของ ticket ให้รัน `git pull --ff-only` บน branch นั้นก่อนเปิด session

```text
ผู้ตรวจส่ง ticket ของ branch นี้กลับ ความเห็นอยู่ใต้ ## Comments
ทำตามขั้น "เริ่มหรือทำต่อ" ใน CLAUDE.md แล้วแก้ทีละความเห็น
ความเห็นที่เป็นพฤติกรรมให้เขียน test ที่ล้มก่อน
ตอบใต้แต่ละความเห็นว่าแก้อย่างไร และ test ไหนครอบการแก้นั้น
```

### P8 แตก milestone เป็น ticket

ใช้เมื่อ: milestone ถัดไปใน `docs/ROADMAP.md` พร้อมเริ่ม ครั้งแรกต้องรัน `/setup-matt-pocock-skills` ก่อน ทำทั้งสามคำสั่งใน session เดียวกันบน branch ของแผน

```bash
git fetch origin
git switch -c plan/<feature> origin/main
```

```text
/grill-with-docs milestone <M1.2> ใน docs/ROADMAP.md ตอบคำถามที่ยังเปิดก่อนเขียน spec
```

```text
/to-spec <M1.2> ตาม docs/ROADMAP.md และ docs/PRD.md หัวข้อ <S1> ใส่ seam ที่ตกลงแล้วในหัวข้อ Testing Decisions
```

```text
/to-tickets
```

จากนั้นสั่ง agent ว่า "commit ไฟล์ของแผนทั้งหมด (spec, ticket และสิ่งที่ /grill-with-docs แก้ใน CONTEXT.md, ADR และ docs/) เป็น `docs(<feature>): spec and tickets`" แล้วคน push เปิด PR ให้อีกคน approve และ squash merge ticket ของ feature นี้ claim ได้หลัง PR นี้เข้า `main` แล้ว

### P9 เปลี่ยน prompt หรือโมเดลของระบบ

ใช้โดย AI lead หรือเมื่อ ticket แตะ `apps/api/prompts/`

```text
ticket ของ branch นี้ แก้ prompt <name>
สร้าง prompt <name> เวอร์ชัน v<N+1> เป็นไฟล์ใหม่ โดยคง v<N> ไว้ตามเดิม ตามกฎใน docs/GUIDELINES.md หัวข้อ 5
รัน make eval-fast ระหว่างแก้ และ make eval เต็มชุดก่อนส่งตรวจ
ทำตารางเทียบกับ baseline ตามรูปแบบใน docs/EVALS.md
```

### P10 ดึงกลับเมื่อ agent หลงทาง

เมื่อ agent ทำนอกขอบเขต:

```text
พอ งานนี้อยู่นอก ticket: <สิ่งที่มันทำ>
ถอยการแก้ใน <ไฟล์> แล้วทำเฉพาะ <สิ่งที่ ticket ขอ>
```

เมื่อ agent แก้ปัญหาเดิมวนหลายรอบ:

```text
พักการแก้โค้ดก่อน สรุปสิ่งที่ลองแล้วทุกทางพร้อมผลของแต่ละทาง
แล้วเสนอสมมติฐานใหม่ 2 ข้อที่ยังไม่ได้ลอง พร้อมวิธีพิสูจน์แต่ละข้อ รอฉันเลือก
```

### P11 เริ่มในเครื่องมืออื่น

ใช้เมื่อ: โควตา Claude ของทุกคนหมดแล้วต้องทำต่อในเครื่องมือสำรองของทีม (ตารางและคำแนะนำใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 8) ใน Cline ให้เริ่มใน Plan mode

```text
อ่าน CLAUDE.md และ AGENTS.md ทั้งไฟล์ และทำตามกฎในนั้นทั้งหมด CLAUDE.md เป็นกติกาของโปรเจกต์สำหรับทุกเครื่องมือ
เอกสารอื่นที่ CLAUDE.md ชี้ไป ให้เปิดเมื่องานตรงกับเงื่อนไข
คำที่ขึ้นต้นด้วย / เป็น skill ให้ทำตามที่ AGENTS.md บอก
จากนั้นทำขั้น "เริ่มหรือทำต่อ" ใน CLAUDE.md กับ ticket ของ branch นี้ ถ้ายังไม่มี Progress note ให้ทำขั้น "วางแผน"
รอฉันตอบว่า "ไป" ก่อนแก้ไฟล์
```

**Aider:** เห็นเฉพาะไฟล์ที่ `/add` หรือ `/read-only` และรันคำสั่ง shell เมื่อคนตอบยืนยันทีละครั้ง (ตอบ No เมื่อขอ `git push`, `reset --hard`, `clean` หรือ `branch -D`) ให้เตรียมแบบนี้ก่อนส่ง prompt

```text
aider --no-auto-commits --no-dirty-commits
/read-only CLAUDE.md AGENTS.md CONTEXT.md docs/GUIDELINES.md docs/ROADMAP.md .scratch/<feature>/spec.md
/add .scratch/<feature>/issues/<NN>-<slug>.md <ไฟล์โค้ดที่จะแก้>
/run git status
/run git log --oneline origin/main..HEAD
/run git show --stat HEAD
/run git diff
```

ตอบ yes เมื่อ Aider ถามว่าจะใส่ผลของ `/run` เข้า chat ไหม ระหว่างทำใช้ `/test <คำสั่ง test>` (Aider เห็นผลเฉพาะตอนล้ม) เมื่อ test ผ่าน ให้พิมพ์ "test ผ่านแล้ว เขียน Progress note ตาม docs/ROADMAP.md" แล้ว `/git status` และ `/git add <ไฟล์ใหม่>` ก่อน `/commit <ข้อความ Conventional Commits>` เพราะเมื่อปิด auto-commit Aider ไม่ add ไฟล์ที่สร้างใหม่ให้

### P12 สรุปงานให้ผู้ตรวจ

ใช้เมื่อ: agent ตั้ง `in-review` แล้ว ก่อนเปลี่ยน draft PR เป็น Ready for review ผลที่ได้ใส่ในคำอธิบาย PR และตั้งชื่อ PR ตาม `docs/GUIDELINES.md` หัวข้อ 7

```text
รัน git fetch origin แล้วสรุป git diff origin/main...HEAD และ git log origin/main..HEAD --oneline สำหรับผู้ตรวจ:
- พฤติกรรมที่เปลี่ยน อ้างถึง acceptance criteria ใน ticket
- test ที่เพิ่ม
- ผล /code-review จากช่อง "ตรวจแล้ว" ใน Progress note: ข้อที่แก้แล้ว และข้อที่ไม่แก้พร้อมเหตุผล
- 3 จุดที่เสี่ยงที่สุดและเหตุผล
- สิ่งที่ยังไม่ได้ทำหรือทำต่างจาก ticket
- วิธีทดสอบด้วยมือ ทีละขั้น
- ชื่อ PR ที่เสนอ ตาม Conventional Commits และลงท้ายด้วย ID ของ ticket
```

### P13 retro

รันบนเครื่องที่ session นั้นเกิด เพราะ `/retro` อ่าน log ของ session จากเครื่องนั้น

```text
/retro <ชื่อหรือคำอธิบาย session ที่มีปัญหา (ดูชื่อจาก /resume) หรือเว้นว่างเพื่อใช้ session นี้>
```

## 3. prompt ที่ควรเปลี่ยน

| ถ้าจะพิมพ์ | พิมพ์แทนว่า | เหตุผล |
| --- | --- | --- |
| "ทำต่อ" เฉยๆ ขณะอยู่บน `main` | `git switch` ไป branch ของ ticket แล้ว P2 | agent หา ticket จากชื่อ branch |
| "แก้ให้หน่อย" | P6 พร้อมอาการและ error | agent ต้องเดาว่าอะไรผิด |
| "ทำทั้ง milestone เลย" | P8 แล้ว P1 ทีละ ticket | งานใหญ่เกิน context เดียว คุณภาพตกช่วงท้าย |
| "ตรวจโค้ดตัวเองว่าดีไหม" | `git fetch origin` แล้ว `/code-review origin/main <path ของไฟล์ ticket>` | ได้การตรวจสองแกนใน context แยก |
| "จำไว้นะว่า..." | แก้ `CLAUDE.md`, `CONTEXT.md` หรือ ADR ผ่าน PR | สิ่งที่พิมพ์ใน chat หายไปเมื่อ `/clear` |
