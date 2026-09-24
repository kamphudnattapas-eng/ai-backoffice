# คู่มือทำงานร่วมกันของทีม

คู่มือนี้สำหรับทีม 3 คนที่ใช้ AI coding agent เขียนโค้ดเป็นหลัก ใช้ตอบว่าใครรับผิดชอบอะไร แบ่งงานอย่างไรไม่ให้ชนกัน ตรวจงานกันอย่างไร และตัดสินใจอย่างไร ส่วนวิธีทำงานกับ agent ใน session หนึ่งอยู่ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) และข้อความ prompt สำเร็จรูปอยู่ใน [`PROMPTS.md`](PROMPTS.md)

## 1. หลัก 5 ข้อของทีม

1. **repo คือความจำของทีม** สิ่งที่ตัดสินใน chat หรือในที่ประชุมจะมีผลเมื่อถูกบันทึกลง repo แล้วเท่านั้น (ticket, เอกสารใน `docs/` หรือ ADR) agent และเพื่อนร่วมทีมจะเห็นแค่สิ่งที่อยู่ใน repo
2. **หนึ่ง ticket มีเจ้าของหนึ่งคน** เจ้าของรับผิดชอบงานจนผ่านการตรวจ ถึงแม้ agent จะเป็นคนเขียนโค้ด
3. **agent ลงมือ คนตัดสิน** agent ส่งงานได้ถึง `in-review` ส่วน `done`, การผ่านประตู และการรับ ADR เป็นของคน (กติกาใน [`../ROADMAP.md`](../ROADMAP.md))
4. **คนตรวจไม่ใช่คนทำ** ทุก PR ต้องมีคนที่ไม่ใช่เจ้าของ ticket approve
5. **ข้อมูลลูกค้าไม่เข้า chat ของ AI** ใช้เอกสารจาก Golden Set สังเคราะห์ใน prompt, test และการ debug (ดู [หัวข้อ 8](#8-ข้อมูล-ความลับ-และบัญชี))

## 2. บทบาท

แต่ละคนเขียนโค้ดผ่าน agent และตรวจ PR ของคนอื่นได้ทุกคน บทบาทบอกว่าใครเป็นเจ้าของเอกสารและเป็นคนตัดสินในเรื่องนั้น ตกลงกันในการประชุมแรกแล้วใส่ชื่อลงในตาราง

| บทบาท | ชื่อ | เป็นเจ้าของ | ตัดสินเรื่อง | ต้องตรวจ PR ที่แตะ |
| --- | --- | --- | --- | --- |
| **Product & Customer lead** | | `docs/PRD.md`, `CONTEXT.md`, การคุยกับ CPA และลูกค้าทดลอง | ขอบเขต feature ลำดับความสำคัญ ข้อความถึงผู้ใช้ | `taxrules`, `control`, ข้อความใน LINE และหน้าเว็บ |
| **Tech lead** | | `docs/ARCHITECTURE.md`, `docs/DATA_MODEL.md`, `docs/API_SPEC.md`, `docs/SECURITY.md`, `docs/GUIDELINES.md`, `docs/adr/` | stack, schema, ความปลอดภัย, การแยก module | auth, tenant, ไฟล์อัปโหลด, secret, migration, การจ่ายเงิน |
| **AI lead** | | `docs/EVALS.md`, `apps/api/prompts/`, Golden Set, pipeline ของ `docai` | prompt, การเลือกโมเดล, เกณฑ์ความแม่น | prompt, โมเดล, pipeline ดึงข้อมูล (ต้องแนบผล eval) |

คำแนะนำในการจับคู่บทบาท: คนที่ถนัดคุยลูกค้าและออกแบบ solution เหมาะกับ Product & Customer lead, คนที่ทำ OCR และ AI engineering มาเหมาะกับ AI lead และอีกคนเป็น Tech lead ถ้ามีคนที่เคยทำทั้ง OCR และ flow agent ให้เป็น AI lead เพราะความแม่นของ OCR ภาษาไทยคือความเสี่ยงใหญ่ที่สุดของเฟส 1

ทีม 3 คนในกลุ่มแชทเดียวกันขอ review กันเองได้ จึงยังไม่ต้องใช้ `.github/CODEOWNERS` ถ้าจะใช้ภายหลัง อย่าเปิด Require review from Code Owners เพราะเมื่อเจ้าของ area เป็นผู้เปิด PR เอง PR นั้นจะ merge ไม่ได้

## 3. จังหวะการทำงาน

| เมื่อไร | ใช้เวลา | ทำอะไร | ผลที่ได้ |
| --- | --- | --- | --- |
| จันทร์เช้า | 30 นาที | ดู "สถานะตอนนี้" ใน `docs/ROADMAP.md`, หา ticket ที่ blocker ครบแล้ว, แบ่งคนละ 1–3 ใบ, ดูงบ AI ของสัปดาห์ | ทุกคนรู้ว่าจะ claim ticket ไหน |
| ทุกวัน (ไม่ต้องประชุม) | 2 นาที | โพสต์ 3 บรรทัดในกลุ่มแชท: เสร็จอะไร (เลข ticket), วันนี้ทำอะไร, ติดอะไร | ปัญหาที่ติดโผล่ภายในวัน |
| ศุกร์บ่าย | 45 นาที | demo ของที่ merge แล้วบนหน้าจอจริง 30 นาที, retro 15 นาที | ของที่ merge ถูกเห็นจริง และมีข้อแก้กระบวนการ 1–3 ข้อ |
| ก่อนประตู G0, G1, … | 1–2 ชั่วโมง | ดูตัวเลขตามเกณฑ์ประตูใน `docs/ROADMAP.md` แล้วตัดสิน | บรรทัดใหม่ในบันทึกของ ROADMAP |

**retro:** เลือก session ที่มีปัญหาในสัปดาห์นั้น (agent หลงทาง ทำผิดกฎ หรือกินเครดิตมาก) แล้วรัน `/retro` กับ session นั้น ข้อเสนอที่ทีมรับให้แก้ใน `CLAUDE.md`, `docs/GUIDELINES.md` หรือเพิ่มเป็น check อัตโนมัติ ทุกการแก้เป็น PR เหมือนโค้ด

## 4. การแบ่งงานไม่ให้ชนกัน

1. **claim ก่อนทำเสมอ** ตามขั้นตอนใน [`../ROADMAP.md`](../ROADMAP.md) หัวข้อ Claim branch `t/<feature>-<NN>` บน remote คือตัวล็อก และ Assignee ของ PR บอกว่าใครถือ ticket ไหน
2. **ทำพร้อมกันได้เมื่ออยู่คนละ module** ถ้าสอง ticket แตะ module เดียวกัน ให้ใส่ "Blocked by" ให้ทำต่อกัน
3. **migration ทีละอัน** Alembic จะมี head ซ้อนถ้ามีสอง PR ที่สร้าง migration พร้อมกัน ให้ merge ทีละ PR แล้ว PR ที่เหลือ `git merge origin/main` และสร้าง migration ใหม่จาก head ล่าสุด
4. **ตาม main ทุกวัน** บน branch ของ ticket รัน `git pull --ff-only` แล้ว `git fetch origin` และ `git merge origin/main` แล้ว `git push` ถ้าชนกันให้ใช้ `/resolving-merge-conflicts` ใช้ merge เสมอ เพราะผู้ตรวจและคนรับต่อก็ push ขึ้น branch นี้ rebase แล้วต้อง force push ซึ่งทับ commit ของคนอื่นได้ และประวัติจะรวมเป็น commit เดียวตอน squash merge อยู่แล้ว
5. **คนเดียวเปิดหลาย agent ได้ (ไม่บังคับ)** เมื่อแต่ละตัวทำคนละ ticket ใน git worktree ของตัวเอง (วิธีอยู่ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 7) และไม่เกิน 2 ตัวต่อคน เพราะคนต้องตรวจงานทุกชิ้นที่ออกมา
6. **ส่งต่องาน** เจ้าของเดิมสั่ง "บันทึกงาน" (หรือ commit `wip:` เองตาม [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 5.3 ถ้าโควตาหมดแล้ว) แล้ว push คนรับต่อทำขั้น "ส่งต่อให้คนอื่น" ใน `docs/ROADMAP.md` แล้วเริ่มด้วย P2 ใน [`PROMPTS.md`](PROMPTS.md) บอกในกลุ่มแชทด้วย เมื่อส่งต่อแล้ว เจ้าของเดิมมี commit ของงานบน branch นั้น จึงเป็นผู้ approve PR นี้ไม่ได้

## 5. Git และ PR

กติกาชื่อ branch, commit, PR และผู้ approve อยู่ใน [`../GUIDELINES.md`](../GUIDELINES.md) หัวข้อ 7 ส่วนนี้คือการตั้งค่าครั้งแรกของ repo ทำตามลำดับ เพราะ branch protection ต้องเปิดหลังสุด ไม่อย่างนั้นทุกขั้นตั้งค่าต้องผ่าน PR

1. **สร้าง repo:** `git init` แล้วสร้าง private repo บน GitHub ใน organization ของทีม ให้ทั้ง 3 คนเป็น member
2. **`.gitignore`:** ใส่ `.env`, `.aider*` และโฟลเดอร์ข้อมูลจริงตั้งแต่ commit แรก ห้ามใส่ `.scratch/` เพราะ ticket อยู่ในนั้น
3. **ติดตั้ง skill เข้า repo:** ทำแล้วในเครื่องแรก (skill 37 ตัวอยู่ใน `.claude/skills/` พร้อม `skills-lock.json`) ขั้นนี้ใช้เมื่อต้องอัปเดต skill ต้นฉบับจริงอยู่ที่ `Claude-Project/.agents/skills/` ส่วน `Claude-Project/.claude/skills/` เป็นแค่ symlink ให้คัดลอกทั้งชุดเป็นโฟลเดอร์จริง เพราะ skill เรียกกันเอง (เช่น `/grill-with-docs` เรียก grilling กับ domain-modeling และ `/tdd` เรียก codebase-design) รันใน Git Bash จากโฟลเดอร์ `ai-backoffice`

   ```bash
   mkdir -p .claude/skills
   cp -r ../../.agents/skills/. .claude/skills/
   cp ../../skills-lock.json .
   ```

4. **กัน agent ไม่ให้สั่ง git อันตราย:** repo นี้มีให้แล้ว 2 ชั้นใน `.claude/settings.json` ชั้นแรกคือ hook `.claude/hooks/block-dangerous-git.sh` (ดัดแปลงจาก `/git-guardrails-claude-code`) ที่จับทั้ง Bash tool และ PowerShell tool อ่านคำสั่งด้วย jq ถ้ามี ถ้าไม่มีจะใช้ Node.js และถ้าไม่มีทั้งคู่จะบล็อกทุกคำสั่งพร้อมข้อความบอก ชั้นที่สองคือกฎ `permissions.deny` ของ `git push`, `reset --hard`, `clean`, `branch -D`, `checkout .` และ `restore .` ทุกเครื่องทดสอบใน Git Bash (ไม่ใช่ PowerShell)

   ```bash
   echo '{"tool_input":{"command":"git push origin main"}}' | bash .claude/hooks/block-dangerous-git.sh; echo $?
   ```

   ต้องได้ `2` จากนั้นใน Claude Code สั่ง agent ให้รัน `git push --dry-run` ด้วย Bash tool และด้วย PowerShell tool ต้องถูกบล็อกทั้งสองครั้ง
5. **ปิด auto memory ของโปรเจกต์นี้:** `.claude/settings.json` ตั้ง `"autoMemoryEnabled": false` ไว้แล้ว auto memory ของ Claude Code เปิดเป็นค่าเริ่มต้น มันเก็บโน้ตของ agent ไว้บนเครื่องแต่ละคนและโหลดทุก session แม้หลัง `/clear` เพื่อนและเครื่องมืออื่นมองไม่เห็น ความจำของงานต้องอยู่ใน ticket กับ git เท่านั้น
6. **ตั้งค่า skill:** รัน `/setup-matt-pocock-skills` เลือก issue tracker แบบ local markdown เพื่อให้ ticket อยู่ใน repo ทุกเครื่องมืออ่านได้ ในไฟล์ `docs/agents/issue-tracker.md` ที่ได้ ให้เขียนว่ากติกาสถานะ claim และ Progress note ของ ticket อยู่ใน `docs/ROADMAP.md` และส่วน Wayfinding ใช้กับ `/wayfinder` เท่านั้น
7. **commit แล้ว push เข้า `main` ครั้งแรก**
8. **เปิดการป้องกัน `main`:** Settings → Rules → Rulesets (หรือ Branches) ของ `main` เปิด Require a pull request before merging (1 approval) และ Block force pushes ไม่ต้องเปิด "Require approval of the most recent reviewable push" เพราะผู้ตรวจ commit `done` ก่อน approve เปิด Require status checks to pass หลัง M0.3 มี CI แล้ว
9. **ตั้งค่า PR:** Settings → General → Pull Requests เปิดเฉพาะ Allow squash merging ตั้ง default commit message เป็น Pull request title และเปิด Automatically delete head branches

GitHub บังคับกฎในข้อ 8 กับ private repo ได้เมื่อ organization ใช้แผน GitHub Team (ราคาต่อคนต่อเดือน ตรวจที่ github.com/pricing) ถ้ายังใช้แผน Free กฎเหล่านี้เป็นแค่ข้อตกลงของทีม agent push เองไม่ได้อยู่แล้วเพราะ guardrails ส่วนคนต้องไม่ push เข้า `main` ตรง และควรซื้อแผนก่อนเข้าเฟส 1 draft PR ใช้ได้ทุกแผน ถ้าใช้ GitLab แผน Free บังคับจำนวน approval ไม่ได้

ถ้าทีมโตเกิน 3–4 คน หรือมีคนนอกเข้ามาช่วย ให้พิจารณาย้าย ticket ไป GitHub Issues โดยรัน `/setup-matt-pocock-skills` ใหม่

## 6. การตรวจงาน

การตรวจหนึ่ง PR มี 3 ชั้น เรียงจากถูกไปแพง

1. **เครื่อง:** CI รัน `make check` ต้องเขียว
2. **agent:** `/code-review` ตรวจสองแกน คือตรงมาตรฐานของ repo และตรงกับ ticket สรุปผลอยู่ในคำอธิบาย PR (จาก P12)
3. **คน:** ผู้ตรวจใช้ checklist ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 6

ใครตรวจ:

- **ผู้ approve** ตามกติกาใน [`../GUIDELINES.md`](../GUIDELINES.md) หัวข้อ 7 (ไม่ใช่ Owner และไม่มี commit ของงานบน branch นั้น) ดูได้ในแท็บ Commits ของ PR
- **งานที่แตะ area** ในคอลัมน์ "ต้องตรวจ PR ที่แตะ" ของหัวข้อ 2: เจ้าของ area เป็นผู้ approve ถ้าเจ้าของ area เป็น Owner หรือมี commit ของงานบน branch นั้นเอง ให้อีกคนที่มีสิทธิ์ approve แทน และเจ้าของ area เขียนจุดที่ต้องตรวจเป็นพิเศษไว้ในคำอธิบาย PR
- **งานที่เพิ่มหรือแก้กฎภาษี:** merge ได้เมื่อ `status` ของกฎเป็น `needs-cpa-review` ตาม `docs/TAX_RULES.md` และใช้กับลูกค้าจริงได้หลัง CPA ยืนยันแล้ว

ผู้ตรวจตอบภายใน 1 วันทำการ วิธีรับงานและส่งกลับบน branch ของ PR อยู่ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 6 ข้อ จ.

## 7. การตัดสินใจ

| ขนาด | ตัวอย่าง | ใครตัดสิน | บันทึกที่ไหน |
| --- | --- | --- | --- |
| เล็ก: กระทบ ticket เดียว | ชื่อฟังก์ชัน วิธีเขียน test | Owner ของ ticket | Progress note ช่อง "ข้อควรรู้" |
| กลาง: กระทบหลาย ticket หรือหลาย module | เพิ่มช่องใน schema เปลี่ยนรูป response | เจ้าของ area ในหัวข้อ 2 | เอกสารใน `docs/` ที่เกี่ยวข้อง ผ่าน PR |
| ใหญ่: ย้อนกลับยาก | เปลี่ยนฐานข้อมูล เปลี่ยนวิธีจ่ายเงิน | ทั้ง 3 คน | ADR ใหม่ใน `docs/adr/` ผ่าน `/grill-with-docs` |

- ถ้าเห็นไม่ตรงกัน เจ้าของ area ตัดสินภายใน 1 วันทำการ แล้วบันทึกเหตุผล
- เรื่องภาษี กฎหมาย และการจ่ายเงิน ให้ถามผู้เชี่ยวชาญภายนอก (CPA หรือทนาย) ก่อนตัดสิน
- ADR ที่ยังเป็น `proposed` ให้ทบทวนในประชุมวันจันทร์ถัดไป แล้วเปลี่ยนเป็น `accepted` หรือเขียนแทนด้วย ADR ใหม่

## 8. ข้อมูล ความลับ และบัญชี

- **เอกสารลูกค้า:** ทุกการทดลองและการ debug ใช้ Golden Set สังเคราะห์ เอกสารจริงของลูกค้าใช้ได้เฉพาะในระบบของเราตาม `docs/SECURITY.md` และใช้ทำ eval ได้เมื่อมีความยินยอมเป็นลายลักษณ์อักษรตาม `docs/EVALS.md`
- **secret:** เก็บใน `.env` บนเครื่องและใน password manager ของทีม (เช่น Bitwarden หรือ 1Password แบบ shared vault) ใส่ใน prompt ด้วยชื่อตัวแปร เช่น `LINE_CHANNEL_SECRET` ถ้า secret หลุดเข้า chat, commit หรือ log ให้เปลี่ยน secret นั้นทันทีแล้วแจ้งในกลุ่ม
- **บัญชี AI:** แต่ละคนใช้บัญชีของตัวเอง รายละเอียดเรื่องงบอยู่ในหัวข้อ 9
- **เครื่อง:** เปิดการเข้ารหัสดิสก์และล็อกหน้าจออัตโนมัติ เพราะเครื่องของทีมจะมีข้อมูลทดสอบและ secret ของ staging

## 9. งบ AI ของทีม

**บัญชีต่อคน:** เงื่อนไขการใช้งานของ Anthropic ห้ามให้คนอื่นใช้ login หรือ API key ของบัญชีตัวเอง บัญชี Pro และ Max จึงใช้ได้คนเดียว ถ้าอยากจ่ายรวมที่เดียว ใช้แผน Team ซึ่งให้แต่ละคนมี login ของตัวเอง (ขั้นต่ำ 2 ที่นั่ง และทุกที่นั่งใช้ Claude Code ได้)

### ราคาอ้างอิง

ราคา ณ ก.ย. 2569 ตรวจที่ claude.com/pricing อีกครั้งก่อนซื้อ

| แผน | ราคาต่อคนต่อเดือน | โควตาเทียบกับ Pro |
| --- | --- | --- |
| Pro | 20 USD รายเดือน หรือ 17 USD เมื่อจ่ายรายปี | 1 เท่า |
| Max 5x | 100 USD | 5 เท่า |
| Max 20x | 200 USD | 20 เท่า |
| Team Standard | 25 USD รายเดือน หรือ 20 USD เมื่อจ่ายรายปี | 1.25 เท่า |
| Team Premium | 125 USD รายเดือน หรือ 100 USD เมื่อจ่ายรายปี | 6.25 เท่า |

ทุกแผนสมาชิกนับโควตาเป็นรอบ 5 ชั่วโมงและมีเพดานรายสัปดาห์ ถ้าโควตาหมด เปิด usage credits เพื่อจ่ายตามใช้ในราคา API ได้

### ตัวอย่างการจัดงบ 200 USD ต่อเดือนสำหรับ 3 คน

| แบบ | ประกอบด้วย | เหมาะเมื่อ |
| --- | --- | --- |
| A (แนะนำสำหรับเฟส 0–1) | Max 5x หนึ่งคน + Pro สองคน = 140 USD เหลือ 60 USD เป็นเพดาน usage credits | มีคนลงมือหลักหนึ่งคน อีกสองคนวางแผน ตรวจ คุยลูกค้า และทำ ticket เล็ก |
| B | Pro สามคน = 60 USD เหลือเพดาน usage credits คนละประมาณ 45 USD | ทุกคนลงมือพอๆ กัน และรับได้ที่จะจ่ายตามใช้ช่วงเร่งงาน |
| C | Team Standard สามที่นั่ง = 75 USD | อยากได้บิลเดียวและจัดการสมาชิกที่เดียว แต่โควตาต่อคนเพียง 1.25 เท่าของ Pro |

ถ้างบ 200 USD เป็นเครดิต API ใน Console แทนแผนสมาชิก ให้สร้าง API key แยกคนละอัน ดูค่าใช้จ่ายด้วย `/usage` และตั้งเพดานการใช้จ่ายในหน้า Billing ของ Console

### กติกาการใช้งบ

- ทุกคนตั้ง monthly spend limit ก่อนเปิด usage credits
- ประชุมวันจันทร์ดูว่าใครใกล้เพดานรายสัปดาห์ คนนั้นรับงานที่ไม่ใช้ AI หรือ ticket เล็ก
- เมื่อโควตาของใครหมด ให้ส่งงานต่อตาม [`AI_WORKFLOW.md`](AI_WORKFLOW.md) หัวข้อ 5.3
- ค่า GitHub Team สำหรับ 3 คน เพื่อบังคับกฎของ `main` ใน private repo ตามหัวข้อ 5 นับอยู่ในงบเครื่องมือของทีม
- ทบทวนการใช้งานจริงทุกสิ้นเดือนที่ claude.ai → Settings → Usage แล้วปรับแบบการจัดงบ
- coding agent ใช้บัญชีของแต่ละคน ส่วน API key ของผลิตภัณฑ์ใช้กับระบบเท่านั้น เพื่อให้ต้นทุน AI ต่อเอกสาร (เป้าไม่เกิน 0.50 บาทตาม `docs/PRD.md`) วัดได้ตรง

## 10. คนใหม่หรือเครื่องใหม่

1. clone repo และติดตั้งเครื่องมือตาม `README.md` หัวข้อติดตั้งบนเครื่อง
2. ติดตั้ง Claude Code (CLI หรือ extension ของ VS Code) แล้ว login ด้วยบัญชีของตัวเอง เปิด repo แล้วพิมพ์ `/` ดูว่ามี `/tdd` และ `/code-review` (ถ้าไม่มี แปลว่ายังไม่ได้ทำขั้น 3 ในหัวข้อ 5)
3. ทดสอบ guardrails ตามหัวข้อ 5 ขั้น 4 ใน Git Bash ให้ได้ `2`
4. อ่าน `README.md`, `CONTEXT.md` และคู่มือในโฟลเดอร์นี้ทั้ง 4 ไฟล์
5. ขอ secret ของ staging จาก Tech lead ผ่าน password manager
6. ticket แรกให้เลือกใบเล็กที่ไม่แตะ area เสี่ยง ทำตาม [`AI_WORKFLOW.md`](AI_WORKFLOW.md) ตั้งแต่ต้นจนถึง merge โดยมีคนในทีมนั่งดู 1 รอบ

## 11. เมื่อมีอะไรพัง

| เหตุการณ์ | ทำอะไร |
| --- | --- |
| `main` พังหลัง merge | เปิด PR ที่ `git revert <sha>` ของ commit นั้นทันที แล้วค่อยหาสาเหตุใน ticket ใหม่ (ใช้ `/diagnosing-bugs`) |
| agent แก้ไฟล์มั่วในเครื่อง | ถอยใน session ด้วย checkpoint ของ Claude Code (หัวข้อ 4 ใน [`AI_WORKFLOW.md`](AI_WORKFLOW.md)) หรือถอยด้วย git ไปที่ commit ล่าสุดที่ดี |
| secret หลุด | เปลี่ยน secret ที่ผู้ให้บริการทันที ลบออกจากที่หลุด แล้วเพิ่มบรรทัดในบันทึกของ ROADMAP |
| ข้อมูลลูกค้ารั่วหรือสงสัยว่ารั่ว | ทำตาม `docs/SECURITY.md` หัวข้อ 13: ข้อมูลของ Firm (เราเป็นผู้ประมวลผล) แจ้ง Firm ทันที เพื่อให้ Firm แจ้ง สคส. ได้ภายใน 72 ชั่วโมงนับจากทราบเหตุ ข้อมูลที่เราเป็นผู้ควบคุมเอง เราแจ้ง สคส. เอง |
