# AGENTS.md

กติกาทั้งหมดของโปรเจกต์นี้อยู่ใน `CLAUDE.md` ที่ root ของ repo อ่านไฟล์นั้นทั้งไฟล์ก่อนเริ่มทุกงาน แล้วทำตามทุกข้อ รวมถึงเอกสารที่ `CLAUDE.md` ชี้ไปตามประเภทงาน

คำที่ขึ้นต้นด้วย `/` เป็น skill ของ Claude Code อยู่ที่ `.claude/skills/<name>/SKILL.md` ถ้าเครื่องมือนี้เรียก skill ไม่ได้ ให้เปิดไฟล์นั้นแล้วทำตามขั้นในไฟล์ ขั้นที่ skill ให้ใช้ subagent ให้ทำเองทีละขั้นใน context นี้

เครื่องมือนี้ไม่มี hook กันคำสั่ง git แบบที่ Claude Code มี คำสั่ง `git push`, `git reset --hard`, `git clean`, `git branch -D`, `git checkout .` และ `git restore .` เป็นหน้าที่ของคน agent commit บน branch ของ ticket แล้วบอกผู้ใช้ว่าพร้อม push

กติกาที่ใช้กับทุกเครื่องมือให้แก้ที่ `CLAUDE.md` ไฟล์นี้เก็บเฉพาะสิ่งที่เครื่องมืออื่นต้องรู้เพิ่ม
