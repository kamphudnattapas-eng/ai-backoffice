---
status: proposed
---

# Modular monolith กับ worker แทน microservices

ทีมมี 3 คน การดูแล microservices กว่า 10 ตัวจะกินเวลามากกว่าการสร้าง product จึงใช้ Python codebase เดียวที่แบ่ง module ชัดเจน คุยกันผ่าน `api.py` ของแต่ละ module และรัน worker 3 ชนิด (`docai`, `control`, `export`) จาก codebase เดียวกัน แยกเป็น service จริงเมื่อเข้าเงื่อนไขใน `docs/ARCHITECTURE.md` หัวข้อ "เมื่อไรค่อยแยกเป็น service" เท่านั้น

## Consequences

ขอบเขต module ต้องถูกรักษาด้วยวินัย (import ได้เฉพาะ `api.py`) เพราะภาษาไม่บังคับให้ ควรเพิ่มเครื่องมือตรวจ import ใน CI
