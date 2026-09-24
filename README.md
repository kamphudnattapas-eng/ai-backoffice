# AI Back-Office

ระบบรับและตรวจเอกสารการเงินด้วย AI สำหรับสำนักงานบัญชีและ SME ไทย ลูกค้าส่งบิลผ่าน LINE ระบบอ่าน ตรวจกฎภาษี จับความผิดปกติ แล้วส่งเข้าโปรแกรมบัญชี

- แผนธุรกิจ: [แผนบริษัท AI Back-Office สำหรับ SME ไทย](https://claude.ai/code/artifact/7eb4875e-a70a-41d4-8aea-862b5dccb8a4) (สำเนาอยู่ใน `../team-share/02-business-plan-ai-backoffice.md`)
- บันทึกการคุยที่มาของโปรเจกต์: `../team-share/01-chat-with-claude.md`

## แผนที่เอกสาร

เอกสารชุดนี้เขียนให้ทั้งทีมและ AI coding agent อ่าน `CLAUDE.md` คือจุดเริ่มของ agent และบอกว่าเปิดเอกสารไหนเมื่อไร

| หมวด | เอกสาร | ใช้ตอบคำถาม |
| --- | --- | --- |
| จุดเริ่ม | [`CLAUDE.md`](CLAUDE.md) | agent ต้องอ่านอะไร ทำงานอย่างไร กฎเหล็กมีอะไร |
| จุดเริ่ม | [`CONTEXT.md`](CONTEXT.md) | คำศัพท์ของโปรเจกต์แปลว่าอะไร ใช้คำไหน |
| 1. ภาพรวมและทิศทาง | [`docs/PRD.md`](docs/PRD.md) | สร้างอะไร ให้ใคร ขอบเขตแต่ละเฟส และเกณฑ์รับงาน |
| 1. ภาพรวมและทิศทาง | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | stack, module, data flow, state ของเอกสาร |
| 1. ภาพรวมและทิศทาง | [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) | ตาราง ความสัมพันธ์ tenant และการเก็บข้อมูล |
| 2. มาตรฐานการพัฒนา | [`docs/GUIDELINES.md`](docs/GUIDELINES.md) | มาตรฐานโค้ด การตั้งชื่อ test และกฎการเขียน prompt |
| 2. มาตรฐานการพัฒนา | [`docs/EVALS.md`](docs/EVALS.md) | วัดความแม่นของ AI อย่างไร และเกณฑ์ก่อน merge |
| 2. มาตรฐานการพัฒนา | [`docs/TAX_RULES.md`](docs/TAX_RULES.md) | กฎตรวจเอกสารและภาษีไทยทุกข้อ |
| 3. ความปลอดภัยและการเชื่อมต่อ | [`docs/API_SPEC.md`](docs/API_SPEC.md) | endpoint, webhook และการเชื่อมระบบภายนอก |
| 3. ความปลอดภัยและการเชื่อมต่อ | [`docs/SECURITY.md`](docs/SECURITY.md) | auth, สิทธิ์, rate limit, PDPA และความปลอดภัยการจ่ายเงิน |
| 4. แผนงานและความจำ | [`docs/ROADMAP.md`](docs/ROADMAP.md) | ตอนนี้อยู่เฟสไหน milestone ไหนเสร็จ ต่อไปทำอะไร |
| 4. แผนงานและความจำ | [`docs/adr/`](docs/adr/) | ทำไมถึงตัดสินใจแบบนี้ |
| 4. แผนงานและความจำ | `.scratch/<feature>/` | spec และ ticket ของงานที่กำลังทำ (สร้างโดย `/to-spec` และ `/to-tickets`) พร้อม Progress note ของแต่ละใบ |
| จุดเริ่มของเครื่องมืออื่น | [`AGENTS.md`](AGENTS.md) | ชี้ Cline, Codex และเครื่องมือที่อ่านแค่ `AGENTS.md` ไปที่ `CLAUDE.md` |

## ติดตั้งบนเครื่อง

รายการเต็มและคำสั่งติดตั้งจะเติมใน M0.3 (scaffold repo) อย่างน้อยต้องมี git (บน Windows ใช้ Git for Windows ซึ่งมี Git Bash), Python 3.12 กับ uv, Node.js กับ pnpm, Docker, make และ Claude Code บน Windows make ไม่ได้มากับ Git for Windows ให้ติดตั้งด้วย `winget install ezwinports.make` แล้วปิดเปิด VS Code ใหม่ ตรวจใน Git Bash ด้วย `make --version` jq ไม่บังคับ (`winget install jqlang.jq`) เพราะ hook กันคำสั่ง git ใช้ Node.js แทนได้ แล้วทำตาม [`docs/guides/TEAMWORK.md`](docs/guides/TEAMWORK.md) หัวข้อ 10

## คู่มือของทีม

เขียนให้คนอ่าน agent ไม่ต้องโหลด

| คู่มือ | ใช้เมื่อ |
| --- | --- |
| [`docs/guides/AI_WORKFLOW.md`](docs/guides/AI_WORKFLOW.md) | ทำงานกับ agent ในแต่ละวัน: คุม context, ล้างความจำ, ทำต่อเมื่อเครดิตหมด, ตรวจงาน, ใช้เครื่องมืออื่น |
| [`docs/guides/PROMPTS.md`](docs/guides/PROMPTS.md) | ต้องการ prompt สำเร็จรูป เช่นเริ่ม ticket, ทำต่อ, บันทึกงาน, แก้บั๊ก |
| [`docs/guides/TEAMWORK.md`](docs/guides/TEAMWORK.md) | แบ่งบทบาท แบ่งงาน ตรวจงานข้ามคน ตัดสินใจ และจัดงบ AI ของทีม |
| [`docs/guides/NEW_PROJECT.md`](docs/guides/NEW_PROJECT.md) | เริ่มโปรเจกต์ใหม่ด้วยวิธีเดียวกับโปรเจกต์นี้ |

## ลำดับการทำงานกับ agent

1. ตั้งค่า repo ครั้งแรกตาม [`docs/guides/TEAMWORK.md`](docs/guides/TEAMWORK.md) หัวข้อ 5 (git, remote, ติดตั้ง skill เข้า repo, guardrails, `/setup-matt-pocock-skills` แบบ local markdown)
2. `/grill-with-docs` ตอบคำถามที่ยังเปิดอยู่ในเอกสาร ผลจะอัปเดต `CONTEXT.md` และ ADR
3. `/prototype` สำหรับคำถามที่ต้องลองจริง เช่นความแม่นของ OCR กับเอกสารไทย
4. `/to-spec` แล้ว `/to-tickets` สำหรับ milestone ถัดไปใน `docs/ROADMAP.md` บน branch `plan/<feature>` แล้วเปิด PR ตาม P8 ใน [`docs/guides/PROMPTS.md`](docs/guides/PROMPTS.md)
5. ทำทีละ ticket ตามวงจรใน [`docs/guides/AI_WORKFLOW.md`](docs/guides/AI_WORKFLOW.md) หัวข้อ 2 และ `/clear` ระหว่าง ticket
