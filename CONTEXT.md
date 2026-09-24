# AI Back-Office

ระบบรับ อ่าน และตรวจเอกสารการเงินของบริษัทไทยแทนสำนักงานบัญชีและ SME ก่อนนำไปลงบัญชีหรือจ่ายเงิน โค้ดใช้ชื่อภาษาอังกฤษตามหัวข้อตัวหนา ส่วนหน้าจอและข้อความ LINE ใช้คำไทยในวงเล็บ

## ผู้ใช้และองค์กร

**Firm** (สำนักงานบัญชี):
สำนักงานบัญชีหรือผู้ทำบัญชีอิสระที่ดูแลบัญชีให้บริษัทลูกค้าหลายราย เป็น tenant ระดับบนสุด
_Avoid_: Accounting office, Agency, Partner

**Client Company** (บริษัทลูกค้า):
นิติบุคคลที่เอกสารของมันถูกส่งเข้าระบบ อยู่ใต้ Firm หนึ่งราย หรืออยู่เดี่ยวเมื่อ SME ใช้ระบบเอง
_Avoid_: Customer, Company, Account, Business

**Direct Company** (บริษัทใช้เอง):
Client Company ที่สมัครใช้ระบบเองโดยไม่ผ่าน Firm ระบบสร้าง Firm เงาให้หนึ่งรายเพื่อให้ tenant model เหมือนกัน
_Avoid_: SME account

**Member** (ผู้ใช้ในสำนักงาน):
คนที่เข้าสู่ระบบในนาม Firm และมี Role กำกับสิทธิ์
_Avoid_: User (เมื่อหมายถึงคนใน Firm), Staff

**Submitter** (ผู้ส่งเอกสาร):
คนฝั่ง Client Company ที่ส่งเอกสารผ่าน LINE หรือ email ไม่ต้องมีรหัสผ่าน ถูกระบุตัวด้วย LINE user ID หรืออีเมล
_Avoid_: Uploader, Sender

**Approver** (ผู้อนุมัติ):
คนฝั่ง Client Company ที่มีสิทธิ์อนุมัติการจ่ายเงิน ใช้ตั้งแต่เฟส 2
_Avoid_: Manager, Signer

## เอกสาร

**Document** (เอกสาร):
ไฟล์หนึ่งชิ้นที่เข้าระบบ เช่นรูปถ่าย PDF หรือ XML หนึ่งไฟล์อาจมีหลายหน้า แต่เป็นเอกสารทางบัญชีหนึ่งฉบับ
_Avoid_: File, Upload, Attachment

**Document Type** (ประเภทเอกสาร):
ชนิดของ Document ที่ระบบรู้จัก ได้แก่ `tax_invoice_full`, `tax_invoice_abbreviated`, `receipt`, `invoice`, `quotation`, `purchase_order`, `goods_receipt`, `wht_certificate`, `bank_slip`, `bank_statement`, `other`
_Avoid_: Category, Kind

**Full Tax Invoice** (ใบกำกับภาษีเต็มรูป):
ใบกำกับภาษีที่มีรายการครบตามมาตรา 86/4 ใช้เคลมภาษีซื้อได้
_Avoid_: VAT invoice, Tax bill

**Abbreviated Tax Invoice** (ใบกำกับภาษีอย่างย่อ):
ใบกำกับภาษีของกิจการค้าปลีกตามมาตรา 86/6
_Avoid_: Short invoice, Receipt (เมื่อหมายถึงใบกำกับภาษีอย่างย่อ)

**WHT Certificate** (หนังสือรับรองการหักภาษี ณ ที่จ่าย / ใบ 50 ทวิ):
หลักฐานว่าผู้จ่ายหักภาษีเงินได้ไว้ ออกโดยผู้จ่ายให้ผู้รับเงิน
_Avoid_: 50 tawi form, Tax certificate

**Vendor** (ผู้ขาย):
คู่ค้าที่ออกเอกสารเรียกเก็บเงินจาก Client Company ระบุด้วยเลขประจำตัวผู้เสียภาษี 13 หลักกับเลขสาขา
_Avoid_: Supplier, Seller, Payee

**Vendor Bank Account** (บัญชีธนาคารผู้ขาย):
เลขบัญชีที่ Vendor ใช้รับเงิน มีสถานะ `unverified` หรือ `verified` และเก็บประวัติทุกครั้งที่เปลี่ยน
_Avoid_: Payee account

## การประมวลผล

**Extraction** (การดึงข้อมูล):
ผลการอ่าน Document หนึ่งครั้ง ได้ Field ตาม schema ของ Document Type นั้น Document หนึ่งมีได้หลาย Extraction เมื่อประมวลผลใหม่
_Avoid_: Parse, OCR result

**Field** (ช่องข้อมูล):
ค่าหนึ่งค่าที่ดึงได้ เช่นเลขประจำตัวผู้เสียภาษีผู้ขาย มีค่า ความมั่นใจ และตำแหน่งในภาพ
_Avoid_: Attribute, Key

**Confidence** (ความมั่นใจ):
คะแนน 0 ถึง 1 ของ Field หนึ่งช่อง ต่ำกว่าเกณฑ์ของ Document Type นั้นแล้วต้องส่งให้คนตรวจ
_Avoid_: Score, Probability

**Check** (การตรวจ):
กฎหนึ่งข้อที่รันกับ Document เช่นตรวจรายการตามมาตรา 86/4 นิยามทุกข้ออยู่ใน `docs/TAX_RULES.md`
_Avoid_: Rule run, Validation

**Finding** (สิ่งที่พบ):
ผลของ Check ที่ไม่ผ่าน มีระดับ `critical`, `warning` หรือ `info` พร้อมหลักฐาน
_Avoid_: Issue, Alert, Error, Flag

**Review Task** (งานตรวจทาน):
งานให้ Member ตรวจ Field ที่ความมั่นใจต่ำหรือตัดสิน Finding
_Avoid_: Ticket, Queue item

**Correction** (คำแก้):
ค่าที่ Member แก้ใน Field ระบบเก็บทุกครั้งเพื่อใช้วัดและปรับปรุงความแม่น
_Avoid_: Edit, Fix, Label

**Ready** (พร้อมลงบัญชี):
สถานะของ Document ที่ไม่มี Finding ระดับ `critical` ค้าง และไม่มี Review Task ค้าง
_Avoid_: Done, Approved, Complete

**Export** (การส่งออก):
ชุดข้อมูลของ Document ที่ Ready ในช่วงเวลาหนึ่ง ในรูปแบบที่โปรแกรมบัญชีปลายทางนำเข้าได้
_Avoid_: Sync, Download, Push

**Leakage Scan** (การตรวจเงินรั่ว):
งานครั้งเดียวที่ตรวจเอกสารย้อนหลังของ Client Company หนึ่งราย แล้วออกรายงานเงินที่อาจรั่วไหล
_Avoid_: Audit, Recovery audit, Health check

**Document Request** (การขอเอกสาร):
ข้อความที่ระบบส่งถึง Submitter เพื่อขอเอกสารที่ขาดหรือขอให้ถ่ายใหม่
_Avoid_: Reminder, Chase

## การจ่ายเงิน (เฟส 2 ขึ้นไป)

**Payment Run** (รอบจ่าย):
ชุดรายการที่จะจ่ายให้ Vendor ในวันหนึ่ง ระบบสร้างเป็นไฟล์ธนาคารหรือส่งผ่าน API ธนาคาร
_Avoid_: Batch, Payout

**Payment Rule** (กฎการจ่าย):
เงื่อนไขที่ Client Company ตั้งไว้ว่ารายการแบบไหนจ่ายอัตโนมัติได้ เช่นวงเงินต่อรายการ
_Avoid_: Mandate (ในโค้ด), Policy, Limit

**Kill Switch** (ปุ่มหยุดฉุกเฉิน):
ค่าตั้งระดับ Client Company ที่ปิดการจ่ายอัตโนมัติทั้งหมดทันที
_Avoid_: Pause, Emergency stop

## คุณภาพ

**Golden Set** (ชุดทดสอบมาตรฐาน):
ชุด Document ที่มีคำตอบถูกต้องครบทุก Field ใช้วัดความแม่นก่อน merge
_Avoid_: Test data, Benchmark
