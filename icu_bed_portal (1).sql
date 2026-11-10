-- Regional Healthcare Facilities and ICU Bed Portal
-- MySQL script

DROP DATABASE IF EXISTS icu_portal_db;
CREATE DATABASE icu_portal_db CHARACTER SET utf8mb4;
USE icu_portal_db;

CREATE TABLE region (
  region_id   INT AUTO_INCREMENT PRIMARY KEY,
  region_name VARCHAR(40) NOT NULL UNIQUE
);
CREATE TABLE facility_type (
  type_id   INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(40) NOT NULL UNIQUE
);
CREATE TABLE facility (
  facility_id   INT AUTO_INCREMENT PRIMARY KEY,
  facility_name VARCHAR(70) NOT NULL UNIQUE,
  type_id       INT NOT NULL,
  region_id     INT NOT NULL,
  ownership     ENUM('Government','Private','Trust') NOT NULL,
  phone         VARCHAR(15),
  FOREIGN KEY (type_id)   REFERENCES facility_type(type_id),
  FOREIGN KEY (region_id) REFERENCES region(region_id)
);
CREATE TABLE ward_type (
  wtype_id   INT AUTO_INCREMENT PRIMARY KEY,
  wtype_name VARCHAR(30) NOT NULL UNIQUE
);
CREATE TABLE facility_ward_rate (
  facility_id  INT NOT NULL,
  wtype_id     INT NOT NULL,
  daily_charge DECIMAL(9,2) NOT NULL CHECK (daily_charge > 0),
  PRIMARY KEY (facility_id, wtype_id),
  FOREIGN KEY (facility_id) REFERENCES facility(facility_id),
  FOREIGN KEY (wtype_id)    REFERENCES ward_type(wtype_id)
);
CREATE TABLE bed (
  bed_id      INT AUTO_INCREMENT PRIMARY KEY,
  facility_id INT NOT NULL,
  wtype_id    INT NOT NULL,
  bed_label   VARCHAR(10) NOT NULL,
  status      ENUM('Available','Occupied','Reserved','Maintenance') DEFAULT 'Available',
  UNIQUE (facility_id, bed_label),
  FOREIGN KEY (facility_id) REFERENCES facility(facility_id),
  FOREIGN KEY (wtype_id)    REFERENCES ward_type(wtype_id)
);

CREATE TABLE severity (
  severity_id   INT AUTO_INCREMENT PRIMARY KEY,
  severity_name VARCHAR(20) NOT NULL UNIQUE,
  priority_rank INT NOT NULL
);
CREATE TABLE patient (
  patient_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name  VARCHAR(60) NOT NULL,
  age        INT NOT NULL CHECK (age >= 0),
  gender     ENUM('M','F','O') NOT NULL,
  phone      VARCHAR(15),
  city       VARCHAR(40)
);
CREATE TABLE staff (
  staff_id    INT AUTO_INCREMENT PRIMARY KEY,
  staff_name  VARCHAR(60) NOT NULL,
  role        VARCHAR(40) NOT NULL,
  facility_id INT NULL,
  FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
);
CREATE TABLE bed_request (
  req_id       INT AUTO_INCREMENT PRIMARY KEY,
  patient_id   INT NOT NULL,
  wtype_id     INT NOT NULL,
  severity_id  INT NOT NULL,
  requested_at DATETIME NOT NULL,
  status       ENUM('Pending','Allocated','Rejected','Cancelled') DEFAULT 'Pending',
  staff_id     INT NULL,
  FOREIGN KEY (patient_id)  REFERENCES patient(patient_id),
  FOREIGN KEY (wtype_id)    REFERENCES ward_type(wtype_id),
  FOREIGN KEY (severity_id) REFERENCES severity(severity_id),
  FOREIGN KEY (staff_id)    REFERENCES staff(staff_id)
);
CREATE TABLE admission (
  adm_id        INT AUTO_INCREMENT PRIMARY KEY,
  req_id        INT NOT NULL UNIQUE,
  bed_id        INT NOT NULL,
  admitted_at   DATETIME NOT NULL,
  discharged_at DATETIME NULL,
  outcome       ENUM('Recovered','Referred','Deceased') NULL,
  FOREIGN KEY (req_id) REFERENCES bed_request(req_id),
  FOREIGN KEY (bed_id) REFERENCES bed(bed_id)
);
CREATE TABLE payment (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  adm_id     INT NOT NULL,
  amount     DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  method     ENUM('Cash','UPI','Insurance','Govt Scheme') NOT NULL,
  pay_date   DATE NOT NULL,
  txn_ref    VARCHAR(30),
  FOREIGN KEY (adm_id) REFERENCES admission(adm_id)
);

INSERT INTO region (region_name) VALUES
 ('Bengaluru Urban'),('Bengaluru Rural'),('Mysuru'),('Tumakuru'),('Mandya');
INSERT INTO facility_type (type_name) VALUES
 ('Medical College Hospital'),('District Hospital'),('Taluk Hospital'),
 ('Community Health Centre'),('Private Multi-speciality');
INSERT INTO ward_type (wtype_name) VALUES
 ('General ICU'),('ICU with Ventilator'),('NICU'),('PICU'),('Cardiac ICU');
INSERT INTO severity (severity_name, priority_rank) VALUES
 ('Critical',1),('Serious',2),('Stable',3);
INSERT INTO facility (facility_name, type_id, region_id, ownership, phone) VALUES
 ('Cauvery District Hospital',2,3,'Government','0821-2400001'),
 ('Namma Medical College Hospital',1,1,'Government','080-22400002'),
 ('Sunrise Multi-speciality Hospital',5,1,'Private','080-41100003'),
 ('Tunga Community Health Centre',4,4,'Government','0816-2500004'),
 ('Kaveri Heart and Critical Care',5,3,'Private','0821-4100005'),
 ('Shivanasamudra Taluk Hospital',3,5,'Government','08232-220006'),
 ('Gateway Super-speciality Hospital',5,2,'Private','080-27300007'),
 ('Lotus Charitable Hospital',5,1,'Trust','080-26600008');

INSERT INTO facility_ward_rate (facility_id, wtype_id, daily_charge) VALUES
 (1,1,1500),
 (1,2,2500),
 (2,1,1500),
 (2,2,2500),
 (2,3,2000),
 (2,4,2000),
 (3,1,7000),
 (3,2,12000),
 (3,5,11000),
 (4,1,1200),
 (5,1,7500),
 (5,5,11500),
 (6,1,1500),
 (6,2,2500),
 (7,1,7000),
 (7,2,12500),
 (7,3,9000),
 (7,4,8500),
 (8,1,3500),
 (8,3,4500);

INSERT INTO bed (facility_id, wtype_id, bed_label, status) VALUES
 (1,1,'A1','Occupied'),
 (1,1,'A2','Available'),
 (1,2,'V1','Occupied'),
 (1,2,'V2','Available'),
 (2,1,'A1','Occupied'),
 (2,1,'A2','Occupied'),
 (2,2,'V1','Available'),
 (2,3,'N1','Occupied'),
 (2,4,'P1','Available'),
 (3,1,'A1','Available'),
 (3,2,'V1','Occupied'),
 (3,5,'C1','Occupied'),
 (3,5,'C2','Available'),
 (4,1,'A1','Available'),
 (4,1,'A2','Maintenance'),
 (5,5,'C1','Occupied'),
 (5,5,'C2','Available'),
 (5,1,'A1','Reserved'),
 (6,1,'A1','Available'),
 (6,2,'V1','Occupied'),
 (7,1,'A1','Available'),
 (7,2,'V1','Available'),
 (7,3,'N1','Available'),
 (7,4,'P1','Occupied'),
 (8,1,'A1','Occupied'),
 (8,1,'A2','Available'),
 (8,3,'N1','Reserved');

INSERT INTO staff (staff_name, role, facility_id) VALUES
 ('Dr. Anil Kumar','State Control Room Coordinator',NULL),
 ('Pooja Hegde','Portal Operator',NULL),
 ('Manjunath S','Hospital Bed Manager',2),
 ('Rekha N','Hospital Bed Manager',3),
 ('Syed Ahmed','Hospital Bed Manager',1),
 ('Prakash Rao','Hospital Bed Manager',7);

INSERT INTO patient (full_name, age, gender, phone, city) VALUES
 ('Ravi Teja',54,'M','9845002001','Mysuru'),
 ('Sunita Devi',67,'F','9845002002','Bengaluru'),
 ('Mahesh Gowda',61,'M','9845002003','Mandya'),
 ('Baby of Radha K',0,'F','9845002004','Bengaluru'),
 ('Imran Pasha',29,'M','9845002005','Tumakuru'),
 ('Aarav Shetty',6,'M','9845002006','Bengaluru'),
 ('Kamala Bai',72,'F','9845002007','Mysuru'),
 ('Narayana Murthy',58,'M','9845002008','Mysuru'),
 ('Fatima Begum',49,'F','9845002009','Bengaluru'),
 ('Harish Kumar',35,'M','9845002010','Bengaluru'),
 ('Baby of Shobha',0,'M','9845002011','Bengaluru'),
 ('Gopal Rao',66,'M','9845002012','Bengaluru'),
 ('Lakshmi Devi',63,'F','9845002013','Bengaluru'),
 ('Venkatesh Prasad',57,'M','9845002014','Mysuru'),
 ('Basavaraj Patil',70,'M','9845002015','Mandya'),
 ('Ananya Reddy',4,'F','9845002016','Hoskote'),
 ('Shanthamma',74,'F','9845002017','Bengaluru'),
 ('Rajesh Naik',52,'M','9845002018','Tumakuru'),
 ('Meena Kumari',45,'F','9845002019','Bengaluru'),
 ('Baby of Anjali',0,'F','9845002020','Mandya');

INSERT INTO bed_request (patient_id, wtype_id, severity_id, requested_at, status, staff_id) VALUES
 (1,1,2,'2026-10-20 08:10','Allocated',2),
 (2,2,1,'2026-10-21 09:30','Allocated',2),
 (3,5,1,'2026-10-22 07:45','Allocated',2),
 (4,3,1,'2026-10-24 11:05','Allocated',2),
 (5,1,3,'2026-10-28 14:20','Allocated',2),
 (6,4,2,'2026-10-29 10:15','Allocated',3),
 (7,1,2,'2026-10-31 09:00','Allocated',5),
 (8,2,1,'2026-11-01 06:50','Allocated',2),
 (9,1,1,'2026-11-01 12:30','Allocated',3),
 (10,1,2,'2026-11-02 08:40','Allocated',3),
 (11,3,1,'2026-11-02 13:10','Allocated',3),
 (12,2,1,'2026-11-03 07:20','Allocated',4),
 (13,5,1,'2026-11-03 10:55','Allocated',4),
 (14,5,2,'2026-11-03 16:25','Allocated',2),
 (15,2,2,'2026-11-04 09:05','Allocated',2),
 (16,4,1,'2026-11-04 11:40','Allocated',6),
 (17,1,2,'2026-11-04 15:30','Allocated',2),
 (18,2,1,'2026-11-05 08:40','Pending',NULL),
 (19,1,2,'2026-11-05 09:10','Pending',NULL),
 (20,3,1,'2026-11-05 09:30','Pending',NULL),
 (2,1,3,'2026-11-03 18:00','Cancelled',2),
 (3,5,1,'2026-11-02 20:15','Rejected',2);

INSERT INTO admission (req_id, bed_id, admitted_at, discharged_at, outcome) VALUES
 (1,2,'2026-10-20 09:15','2026-10-24 12:00','Recovered'),
 (2,7,'2026-10-21 10:20','2026-10-27 11:30','Recovered'),
 (3,13,'2026-10-22 08:30','2026-10-26 10:00','Recovered'),
 (4,23,'2026-10-24 12:10','2026-11-01 09:45','Recovered'),
 (5,14,'2026-10-28 15:00','2026-10-30 11:00','Referred'),
 (6,9,'2026-10-29 11:00','2026-11-02 12:30','Recovered'),
 (7,1,'2026-10-31 09:40',NULL,NULL),
 (8,3,'2026-11-01 07:30',NULL,NULL),
 (9,5,'2026-11-01 13:10',NULL,NULL),
 (10,6,'2026-11-02 09:20',NULL,NULL),
 (11,8,'2026-11-02 13:50',NULL,NULL),
 (12,11,'2026-11-03 08:00',NULL,NULL),
 (13,12,'2026-11-03 11:30',NULL,NULL),
 (14,16,'2026-11-03 17:00',NULL,NULL),
 (15,20,'2026-11-04 09:45',NULL,NULL),
 (16,24,'2026-11-04 12:15',NULL,NULL),
 (17,25,'2026-11-04 16:10',NULL,NULL);

CREATE VIEW v_bill AS
SELECT a.adm_id, p.full_name, f.facility_name, wt.wtype_name,
       GREATEST(1, DATEDIFF(COALESCE(a.discharged_at,'2026-11-05 10:00:00'), a.admitted_at)) AS days,
       GREATEST(1, DATEDIFF(COALESCE(a.discharged_at,'2026-11-05 10:00:00'), a.admitted_at)) * fr.daily_charge AS total_bill,
       COALESCE(pm.paid, 0) AS paid
FROM admission a
JOIN bed_request r ON r.req_id = a.req_id
JOIN patient p     ON p.patient_id = r.patient_id
JOIN bed b         ON b.bed_id = a.bed_id
JOIN facility f    ON f.facility_id = b.facility_id
JOIN ward_type wt  ON wt.wtype_id = b.wtype_id
JOIN facility_ward_rate fr ON fr.facility_id = b.facility_id AND fr.wtype_id = b.wtype_id
LEFT JOIN (SELECT adm_id, SUM(amount) AS paid FROM payment GROUP BY adm_id) pm
       ON pm.adm_id = a.adm_id;

INSERT INTO payment (adm_id, amount, method, pay_date, txn_ref) VALUES
 (1,1000,'UPI','2026-10-20','UPI66010001'),(2,2000,'Cash','2026-10-21','RCPT-1002'),
 (3,5000,'UPI','2026-10-22','UPI66010003'),(4,3000,'Cash','2026-10-24','RCPT-1004'),
 (5,500,'Cash','2026-10-28','RCPT-1005'),(6,2000,'UPI','2026-10-29','UPI66010006'),
 (7,1500,'UPI','2026-10-31','UPI66010007'),(8,5000,'Govt Scheme','2026-11-01','AB-ARK-0008'),
 (9,3000,'Govt Scheme','2026-11-01','AB-ARK-0009'),(12,20000,'Insurance','2026-11-03','INS-5512'),
 (13,15000,'UPI','2026-11-03','UPI66010013'),(14,10000,'Cash','2026-11-03','RCPT-1014'),
 (16,10000,'UPI','2026-11-04','UPI66010016');

INSERT INTO payment (adm_id, amount, method, pay_date, txn_ref)
SELECT b.adm_id, b.total_bill - b.paid,
       CASE f.ownership WHEN 'Government' THEN 'Govt Scheme'
                        WHEN 'Private' THEN 'Insurance' ELSE 'UPI' END,
       DATE(a.discharged_at), CONCAT('SETTLE-', b.adm_id)
FROM v_bill b
JOIN admission a ON a.adm_id = b.adm_id
JOIN bed bd ON bd.bed_id = a.bed_id
JOIN facility f ON f.facility_id = bd.facility_id
WHERE a.discharged_at IS NOT NULL AND b.total_bill > b.paid;

SELECT f.facility_name, r.region_name, b.bed_label, fr.daily_charge
FROM bed b
JOIN facility f ON f.facility_id = b.facility_id
JOIN region r   ON r.region_id = f.region_id
JOIN facility_ward_rate fr ON fr.facility_id = b.facility_id AND fr.wtype_id = b.wtype_id
WHERE b.wtype_id = 2 AND b.status = 'Available'
ORDER BY fr.daily_charge;

INSERT INTO patient (full_name, age, gender, phone, city)
VALUES ('Mohan Das', 59, 'M', '9845012021', 'Bengaluru');

INSERT INTO bed_request (patient_id, wtype_id, severity_id, requested_at, staff_id)
VALUES (LAST_INSERT_ID(), 1, 2, '2026-11-05 10:05:00', 2);

SELECT r.req_id, p.full_name, wt.wtype_name, s.severity_name,
       TIMESTAMPDIFF(MINUTE, r.requested_at, '2026-11-05 10:10:00') AS waiting_min
FROM bed_request r
JOIN patient p    ON p.patient_id = r.patient_id
JOIN ward_type wt ON wt.wtype_id = r.wtype_id
JOIN severity s   ON s.severity_id = r.severity_id
WHERE r.status = 'Pending'
ORDER BY s.priority_rank, r.requested_at;

START TRANSACTION;
INSERT INTO admission (req_id, bed_id, admitted_at) VALUES (18, 22, '2026-11-05 10:20:00');
UPDATE bed SET status = 'Occupied' WHERE bed_id = 22;
UPDATE bed_request SET status = 'Allocated', staff_id = 2 WHERE req_id = 18;
COMMIT;

SELECT full_name, wtype_name, days, total_bill, paid, total_bill - paid AS balance
FROM v_bill WHERE adm_id = 7;

START TRANSACTION;
UPDATE admission SET discharged_at = '2026-11-05 11:00:00', outcome = 'Recovered' WHERE adm_id = 7;
INSERT INTO payment (adm_id, amount, method, pay_date, txn_ref)
SELECT adm_id, total_bill - paid, 'Govt Scheme', '2026-11-05', 'AB-ARK-0107'
FROM v_bill WHERE adm_id = 7;
UPDATE bed SET status = 'Available' WHERE bed_id = 1;
COMMIT;

SELECT rg.region_name, COUNT(*) AS total_beds,
       SUM(b.status = 'Available') AS available,
       SUM(b.status = 'Occupied')  AS occupied,
       ROUND(100 * SUM(b.status = 'Occupied') / COUNT(*), 1) AS occupancy_pct
FROM bed b
JOIN facility f ON f.facility_id = b.facility_id
JOIN region rg  ON rg.region_id = f.region_id
GROUP BY rg.region_name
ORDER BY occupancy_pct DESC;

SELECT wt.wtype_name, COUNT(*) AS total_beds,
       SUM(b.status = 'Available') AS available,
       SUM(b.status = 'Occupied')  AS occupied
FROM bed b JOIN ward_type wt ON wt.wtype_id = b.wtype_id
GROUP BY wt.wtype_name
ORDER BY available;

SELECT f.facility_name, f.ownership, COUNT(*) AS beds,
       ROUND(100 * SUM(b.status = 'Occupied') / COUNT(*), 1) AS occupancy_pct
FROM bed b JOIN facility f ON f.facility_id = b.facility_id
GROUP BY f.facility_id, f.facility_name, f.ownership
HAVING occupancy_pct >= 50
ORDER BY occupancy_pct DESC;

SELECT wt.wtype_name, COUNT(*) AS discharges,
       ROUND(AVG(DATEDIFF(a.discharged_at, a.admitted_at)), 1) AS avg_stay_days
FROM admission a
JOIN bed b        ON b.bed_id = a.bed_id
JOIN ward_type wt ON wt.wtype_id = b.wtype_id
WHERE a.discharged_at IS NOT NULL
GROUP BY wt.wtype_name
ORDER BY avg_stay_days DESC;

SELECT f.ownership, COUNT(DISTINCT a.adm_id) AS admissions,
       SUM(p.amount) AS amount_collected
FROM payment p
JOIN admission a ON a.adm_id = p.adm_id
JOIN bed b       ON b.bed_id = a.bed_id
JOIN facility f  ON f.facility_id = b.facility_id
GROUP BY f.ownership
ORDER BY amount_collected DESC;

SELECT full_name, facility_name, total_bill
FROM v_bill
WHERE total_bill > (SELECT AVG(total_bill) FROM v_bill)
ORDER BY total_bill DESC;

SELECT (SELECT COUNT(*) FROM bed)                            AS total_beds,
       (SELECT COUNT(*) FROM bed WHERE status='Available')   AS available,
       (SELECT COUNT(*) FROM bed WHERE status='Occupied')    AS occupied,
       (SELECT COUNT(*) FROM bed_request WHERE status='Pending') AS pending_requests,
       (SELECT ROUND(AVG(total_bill),0) FROM v_bill)         AS avg_bill;
