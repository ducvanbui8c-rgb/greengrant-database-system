# GreenGrant Proposal Review Board - Database System

## 📌 Project Overview
This repository contains the complete implementation of the relational database management system (RDBMS) for the **GreenGrant Proposal Review Board**. The system is engineered to handle scientific research proposals, coordinate multi-expert double-blind peer reviews, track publication layouts, and enforce core business rules at the database level.

* **Course:** Database Management Systems (CSDL)
* **Class:** ISV201603
* **Instructor:** Dr. Vu Duc Minh
* **Group:** Team 6

---

## 👥 Authors (Team 6)
1. **Nguyen Duy Khiem** (Team Leader) - Student ID: 24070525
2. **Bui Van Duc** - Student ID: 24070706
3. **Pham Gia Khanh** - Student ID: 24070600
4. **Tran Trung Kien** - Student ID: 24070476

---

## ⚡ Features
* **Double-Blind Peer Review Coordination:** Automated verification workflows to assign multiple independent experts to individual scientific proposals without role conflicts.
* **Reactive Status Engine:** Built-in triggers to automate state machine transitions from `received` to `under review`, `scheduled`, and `published`.
* **Database-Level Integrity Constraints:** Bulletproof data validation using composite unique constraints, auto-increment keys, and custom transaction error-handling.
* **Performance Optimization:** Structural query tuning through composite and covering index deployments, minimizing expensive `Filesort` and disk I/O.
* **Role-Based Access Control (RBAC):** Implementation of the Principle of Least Privilege (PoLP) via custom database roles and secure virtual layout views.

---

## 🛠️ Tech Stack
* **Database Server:** MySQL 8.0+ / Enterprise Edition
* **Storage Engine:** InnoDB (Supporting ACID transactions, row-level locking, and foreign keys)
* **Data Formatting:** `utf8mb4` (Unicode Case-Insensitive collation)
* **Design Pattern:** Third Normal Form (3NF) & Boyce-Codd Normal Form (BCNF) compliance
* **Administration Tools:** MySQL Workbench, `mysqldump` CLI

---

## 📂 Repository Structure & Execution Order
To deploy the database seamlessly in a local laboratory environment, execute the scripts sequentially as ordered below:

1. 📜 `01_schema.sql` — Initializes the `greengrant` schema, tables, and physical constraints (Data Definition Language).
2. 📜 `02_seed_data.sql` — Populates the database with comprehensive mock assets and transactional data for system testing.
3. 📜 `05_routines.sql` — Stored Functions and Procedures integrated with Transaction Control (COMMIT/ROLLBACK).
4. 📜 `06_triggers_events.sql` — Reactive architecture implementing automated status updates and orphan cleanup triggers.
5. 📜 `04_views.sql` — Virtual layout views optimized for the Editorial Board and Review Council.
6. 📜 `07_indexes_explain.sql` — Query optimization using Composite/Covering Indexes analyzed via EXPLAIN.
7. 📜 `03_queries.sql` — Advanced business query pack containing 8 operational scenarios (JOINs, CTEs, Anti-Joins).
8. 📜 `08_admin_backup.sql` — Role-Based Access Control (RBAC) security setup and database backup (mysqldump) runbooks.
9. 📜 `09_tests.sql` — Black-box validation suite utilizing Positive and Negative Test cases to evaluate database constraints.

---

## 📸 Screenshots
*(Note: Please refer to Chapter 5, 6, and 7 of the main `report.pdf` submitted along with this project to view complete photographic proof of execution, query execution trees, and physical ERD diagrams.)*

---

## 🔧 Installation & Deployment Guide

### Prerequisites
* MySQL Server (v8.0 or higher) installed locally or on a laboratory workstation.
* Terminal/Command Prompt access with administrative privileges or MySQL Workbench IDE.

### Step-by-Step Lab Setup
1. Clone the repository to your local directory:
   ```bash
   git clone [https://github.com/ducvanbui8c-rgb/greengrant-database-system.git](https://github.com/ducvanbui8c-rgb/greengrant-database-system.git)
   cd greengrant-database-system
