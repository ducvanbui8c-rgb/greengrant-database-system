# GreenGrant Proposal Review Board - Database System

## 📌 Project Overview
This repository contains the complete implementation of the relational database management system (RDBMS) for the **GreenGrant Proposal Review Board**. The system is engineered to handle scientific research proposals, coordinate multi-expert double-blind peer reviews, track publication layouts, and enforce core business rules at the database level.

* **Course:** Database Management Systems (CSDL)
* **Class:** ISV201603
* **Instructor:** Dr. Vu Duc Minh
* **Group:** Team 6

## 👥 Authors (Team 6)
1. **Nguyen Duy Khiêm** (Team Leader) - Student ID: 24070525
2. **Bui Van Duc** - Student ID: 24070706
3. **Pham Gia Khánh** - Student ID: 24070600
4. **Tran Trung Kien** - Student ID: 24070476

---

## 📂 Repository Structure & Execution Order
To deploy the database seamlessly in a local laboratory environment, execute the scripts sequentially as ordered below:

1. 📜 `01_schema.sql` — Initializes the `greengrant` schema, tables, and physical constraints (Data Definition Language).
2. 📜 `02_seed_data.sql` — Populates the database with comprehensive mock assets and transactional data for system testing.
3. 📜 `03_queries.sql` — Advanced business query pack containing 8 operational scenarios (JOINs, CTEs, Anti-Joins).
4. 📜 `04_views.sql` — Virtual layout views optimized for the Editorial Board and Review Council.
5. 📜 `05_routines.sql` — Stored Functions and Procedures integrated with Transaction Control (COMMIT/ROLLBACK).
6. 📜 `06_triggers_events.sql` — Reactive architecture implementing automated status updates and orphan cleanup triggers.
7. 📜 `07_indexes_explain.sql` — Query optimization using Composite/Covering Indexes analyzed via EXPLAIN.
8. 📜 `08_admin_backup.sql` — Role-Based Access Control (RBAC) security setup and database backup (mysqldump) runbooks.
9. 📜 `09_tests.sql` — Black-box validation suite utilizing Positive and Negative Test cases to evaluate database constraints.

---

## 🛠️ Technical Specifications
* **Database Engine:** MySQL 8.0+ / InnoDB Engine
* **Character Set:** `utf8mb4` (Unicode CI)
* **Normalization Level:** Fully compliant with 3rd Normal Form (3NF) / Boyce-Codd Normal Form (BCNF)
* **Security Model:** Principle of Least Privilege (PoLP) via custom `ROLE` abstractions.
