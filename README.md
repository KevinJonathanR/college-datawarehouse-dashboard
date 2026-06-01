# Research & Publication Data Warehouse
### Fakultas Informatika — Universitas Telkom (2021–2025)

A team project building an end-to-end **data warehouse and business intelligence dashboard** for the Faculty of Informatics at Telkom University. The system consolidates 4 years of research and publication data from multiple Excel sources into a single analytical platform, enabling the faculty to monitor research trends, publication output, citation metrics, and lecturer productivity.

---

## Dashboard Preview

> **Power BI Dashboard** — hosted and connected to Railway MySQL

<!-- Add your Power BI screenshots here -->
<!-- Tip: export as PNG from Power BI, place in docs/assets/, then uncomment below -->

<!-- ![Dashboard Overview](docs/assets/dashboard-overview.png) -->
<!-- ![Research Trends](docs/assets/dashboard-research-trends.png) -->
<!-- ![Publication Metrics](docs/assets/dashboard-publication-metrics.png) -->

### KPIs Tracked

| # | Focus Area | Metrics |
|---|---|---|
| 1 | **Lecturer & Study Program Performance** | Avg. publications per lecturer · Research & publication distribution by study program · Student involvement rate in research |
| 2 | **Research Funding** | Total grant absorption · Fund efficiency ratio (grant received vs. spent) |
| 3 | **Publication Quality & Impact** | Citation count per publication · Percentage of internationally/nationally indexed publications |
| 4 | **Research Collaboration** | International collaboration reach · Collaborator type breakdown (industry vs. university) |
| 5 | **Research Efficiency** | Research-to-publication conversion rate · Avg. time from research to publication · Avg. citations per research |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Source Data | Microsoft Excel (`.xlsx`) |
| ETL & Warehouse | MySQL 8.0 |
| Cloud Hosting | Railway |
| BI Dashboard | Microsoft Power BI |
| Version Control | Git / GitHub |

---

## Architecture

The warehouse follows a **3-layer ETL architecture**:

```
 ┌─────────────────────────────────────────────────────────────────┐
 │                        SOURCE DATA                              │
 │         Excel: penelitianAll_final.csv / publikasi.csv          │
 └───────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │  LAYER 1 — EXTRACT          (DW_penelitianPublikasi_layer1Extract) │
 │                                                                 │
 │  raw_penelitian2021_2025    raw_publikasi_2020_2025             │
 │  (seluruh kolom TEXT,       (seluruh kolom TEXT,                │
 │   load langsung dari CSV)    load langsung dari CSV)            │
 └───────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │  LAYER 2 — TRANSFORM      (DW_penelitianPublikasi_layer2Transform) │
 │                                                                 │
 │  Cleaning, deduplication, data quality scoring                  │
 │                                                                 │
 │  transform_dosen        transform_penelitian                    │
 │  transform_publikasi    transform_kolaborator                   │
 │  transform_waktu                                                │
 └───────────────────────────┬─────────────────────────────────────┘
                             │
                             ▼
 ┌─────────────────────────────────────────────────────────────────┐
 │  LAYER 3 — LOAD              (DW_penelitianPublikasi_layer3Load) │
 │                                                                 │
 │         Star Schema — ready for Power BI                        │
 │                                                                 │
 │   dim_dosen        dim_penelitian    dim_publikasi              │
 │   dim_kolaborator  dim_waktu                                    │
 │                                                                 │
 │              Fact_PenelitianPublikasi                           │
 │    (id_dosen, id_penelitian, id_publikasi, id_kolaborator,      │
 │     id_waktu, jumlah_sitasi, jumlah_hibah, dana_terpakai)       │
 └─────────────────────────────────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    Railway      │  ← MySQL hosted in cloud
                    │    (MySQL)      │
                    └────────┬────────┘
                             │  DirectQuery / Import
                             ▼
                    ┌─────────────────┐
                    │   Power BI      │  ← Dashboard & analytics
                    └─────────────────┘
```

---

## Star Schema (Layer 3)

[Star Schema](docs/assets/final_starSchema_DWH.png)

---

## Project Structure

```
college-datawarehouse-dashboard/
│
├── sql/
│   ├── 01_init_database_3layer.sql          # Create 3 databases (layer 1-2-3)
│   │
│   ├── layer1-extract/
│   │   ├── 02_data_penelitian.sql           # DDL + LOAD DATA for raw research table
│   │   └── 03_data_publikasi.sql            # DDL + LOAD DATA for raw publication table
│   │
│   ├── layer2-transform/
│   │   ├── 04_dim_dosen.sql                 # Clean & deduplicate lecturer data
│   │   ├── 05_dim_kolaborator.sql           # Extract collaborator dimension
│   │   ├── 06_dim_penelitian.sql            # Transform research dimension
│   │   ├── 07_dim_publikasi.sql             # Transform publication dimension
│   │   └── 08_dim_waktu.sql                 # Build time dimension
│   │
│   └── layer3-load/
│       └── 09_fact_penelitian_publikasi.sql # Build star schema + fact table
│
└── docs/
    └── assets/                              # Architecture diagrams, ERD, screenshots
```

> **Note:** The `dumping-warehouse/` folder and all raw data files (`.csv`, `.xlsx`) are excluded from this repository via `.gitignore` to protect confidential faculty data.

---

## How to Run Locally

**Prerequisites:** MySQL 8.0+, a MySQL client (e.g. MySQL Workbench / DBeaver), and the raw data files from the faculty.

```bash
# Step 1 — initialize the 3 layer databases
mysql -u root -p < sql/01_init_database_3layer.sql

# Step 2 — extract raw data (update the INFILE path in each script first)
mysql -u root -p < sql/layer1-extract/02_data_penelitian.sql
mysql -u root -p < sql/layer1-extract/03_data_publikasi.sql

# Step 3 — transform & clean
mysql -u root -p < sql/layer2-transform/04_dim_dosen.sql
mysql -u root -p < sql/layer2-transform/05_dim_kolaborator.sql
mysql -u root -p < sql/layer2-transform/06_dim_penelitian.sql
mysql -u root -p < sql/layer2-transform/07_dim_publikasi.sql
mysql -u root -p < sql/layer2-transform/08_dim_waktu.sql

# Step 4 — build star schema & fact table
mysql -u root -p < sql/layer3-load/09_fact_penelitian_publikasi.sql
```

> Before running Layer 1, update the `INFILE` path in `02_data_penelitian.sql` and `03_data_publikasi.sql` to point to your local CSV files.

---

## Key Features

- **Multi-source integration** — merges research and publication data from separate Excel files into one unified warehouse
- **Data quality scoring** — lecturers scored based on completeness of NIDN and lecturer code, with deduplication logic prioritizing highest-quality records
- **Full ETL separation** — raw, transformed, and analytical layers are kept in separate MySQL databases for traceability and reprocessing
- **Star schema** — fact table bridges research, publication, lecturer, collaborator, and time dimensions for flexible OLAP queries
- **Cloud-hosted** — final Layer 3 database deployed to Railway, directly connected to Power BI

---

## Data Privacy

This project uses **real faculty data** from Fakultas Informatika, Universitas Telkom. To comply with data confidentiality:

- All raw data files (CSV, Excel) are excluded from this repository
- Database dumps containing lecturer PII (name, NIDN) are excluded via `.gitignore`
- Only the ETL logic (SQL scripts) and documentation are published

Raw data access is restricted to authorized team members only.

---

## Team

Built by a student team from Fakultas Informatika, Universitas Telkom as part of a data warehouse & business intelligence course project.

### Data Warehouse Team:
1. Kevin Jonathan Rotty - Team Lead [@KevinJonathanR](https://github.com/KevinJonathanR)
2. Frenwin
3. Vadly Aryu Septian
4. Rifa Mayshakori
5. Ekmal Reyhan Tarihoran
6. M. Zikra Al Rizkya

### Dashboard Team:
1. Kevin Jonathan Rotty - Team Lead
2. Muhammad Rafif
3. Justin Jeremia
4. Eliezer Sharon
5. Syahrul Surya
