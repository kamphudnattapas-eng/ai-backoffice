---
status: proposed
---

# PostgreSQL ฐานเดียว แยก tenant ด้วย row-level security

ข้อมูลรั่วข้าม Firm คือความเสียหายที่แรงที่สุดของระบบนี้ การแยกฐานข้อมูลต่อ Firm แพงเกินไปสำหรับลูกค้าหลักร้อยราย และการกรองด้วย `WHERE firm_id = ...` ในโค้ดพลาดได้ง่าย จึงใช้ฐานเดียวที่ทุกตารางมี `firm_id` และเปิด row-level security โดยแอปตั้ง `app.firm_id` ต่อ transaction จาก session และ role ของแอปไม่มี `BYPASSRLS` เก็บ embedding ใน pgvector ในฐานเดียวกันเพื่อไม่ต้องดูแลฐานข้อมูล vector แยก

## Considered Options

- ฐานข้อมูลหรือ schema แยกต่อ Firm: แยกได้แข็งกว่า แต่ migration และค่าใช้จ่ายโตตามจำนวนลูกค้า
- vector database แยก: ตัดออกจนกว่าปริมาณ embedding จะเกินที่ pgvector รับได้
