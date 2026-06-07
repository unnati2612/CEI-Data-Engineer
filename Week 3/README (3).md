# Superstore Sales Analysis — SQL (Subqueries, CTEs, Window Functions)

## Overview

This project analyzes sales data from the **Sample Superstore** dataset using SQL.  
The focus is on three advanced SQL techniques:

- **Subqueries** — filtering rows against computed aggregates
- **CTEs (Common Table Expressions)** — clean, readable multi-step aggregations
- **Window Functions** — ranking and row numbering without collapsing rows

---

## Repository Structure

```
.
├── dataset_csv.xlsx            # Original dataset (source file)
├── superstore.csv              # Dataset exported as CSV (used by notebook/script)
├── superstore_analysis.sql     # Complete SQL script — all queries
├── superstore_analysis.ipynb   # Jupyter Notebook — SQL via DuckDB + full results
└── README.md
```

---

## Dataset

| Property | Value |
|---|---|
| Source | Sample Superstore |
| Rows | 9,994 |
| Years | 2014 – 2017 |
| Customers | 793 unique |
| Products | 1,894 unique |

| Column | Description |
|---|---|
| Order ID | Unique order identifier |
| Order Date | Date the order was placed |
| Customer ID / Name | Customer reference |
| Segment | Consumer / Corporate / Home Office |
| Region | East / West / Central / South |
| Product ID / Name | Product reference |
| Category / Sub-Category | Product classification |
| Sales | Order line sale amount (USD) |
| Quantity | Units ordered |
| Discount | Discount applied (0–0.5) |
| Profit | Profit on the order line |

---

## Step 1 — Data Setup

Three normalised tables are created from `superstore_raw` using `SELECT DISTINCT`:

| Table | Rows | Key Columns |
|---|---|---|
| `customers` | 793 | customer_id, customer_name, segment, region |
| `products` | 1,894 | product_id, product_name, category, sub_category |
| `orders` | 9,994 | order_id, order_date, customer_id, product_id, sales, quantity, discount, profit |

---

## Step 2 — Required Queries

| # | Query | Technique |
|---|---|---|
| 1 | Orders where sales > average sales | Subquery |
| 2 | Highest sales order per customer | Correlated Subquery |
| 3 | Total sales per customer | CTE |
| 4 | Customers with above-average total sales | CTE + Subquery |
| 5 | Rank all customers by total sales | Window Function — `RANK()` |
| 6 | Row numbers per order within each customer | Window Function — `ROW_NUMBER()` + `PARTITION BY` |
| 7 | Top 3 customers by total sales | Window Function — `DENSE_RANK()` |

---

## Step 3 — Final Combined Query

A single query combining **JOIN + CTE + Window Function** that returns:

| Customer Name | Total Sales | Rank |
|---|---|---|
| Sean Miller | 100,172.20 | 1 |
| Tamara Chand | 76,208.87 | 2 |
| Raymond Buch | 60,469.36 | 3 |
| Adrian Barton | 57,894.28 | 4 |
| Sanjit Chand | 56,569.34 | 5 |
| ... | ... | ... |

---

## Mini Project — Customer Sales Insights

| Question | Result |
|---|---|
| Top 5 customers | Sean Miller, Tamara Chand, Raymond Buch, Adrian Barton, Sanjit Chand |
| Bottom 5 customers | Lela Donovan ($5.30), Thais Sissman ($9.67), Carl Jackson ($16.52), Mitch Gastineau ($16.74), Roy Skaria ($44.66) |
| Customers with only 1 order | 12 customers (Anemone Ratner, Carl Jackson, Lela Donovan, and 9 others) |
| Customers with above-average sales | 108 out of 793 customers (≈13.6%) |
| Highest order value per customer | Sean Miller — $22,638.48 (Order CA-2014-145317) |

---

## Key Business Insights

1. **Sean Miller** is the top customer at **$100,172** in total sales — 31% above the second-ranked customer Tamara Chand ($76,208).
2. Only **13.6% of customers** (108/793) are above average in sales, indicating a concentrated high-value customer segment.
3. **12 customers** placed exactly one order — a re-engagement opportunity.
4. The **bottom 5 customers** have combined sales under $100, whereas the top customer alone exceeds $100,000.
5. **Sean Miller's single highest order** ($22,638) is more than double the next best single order, suggesting a large one-time technology or furniture purchase.
6. Window functions allow ranking and row sequencing **without losing row-level detail** — a major advantage over `GROUP BY` alone.

---

## How to Run

### Option A — Jupyter Notebook (Recommended)
```bash
pip install duckdb pandas openpyxl jupyter
# Convert the xlsx to csv first (or use the included superstore.csv)
jupyter notebook superstore_analysis.ipynb
```

### Option B — SQL Script via DuckDB CLI
```bash
pip install duckdb
python3 -c "
import duckdb, pandas as pd
df = pd.read_excel('dataset_csv.xlsx')
df.to_csv('superstore.csv', index=False)
con = duckdb.connect('superstore.db')
con.execute(\"CREATE OR REPLACE TABLE superstore_raw AS SELECT * FROM read_csv_auto('superstore.csv', header=True)\")
con.close()
"
duckdb superstore.db < superstore_analysis.sql
```

### Option C — Any Standard SQL Engine
The SQL in this project uses standard ANSI SQL compatible with:
- PostgreSQL
- MySQL 8+
- SQLite 3.25+
- DuckDB
- BigQuery / Snowflake / Redshift

---

## Requirements

- Python 3.8+
- `duckdb` — `pip install duckdb`
- `pandas` — `pip install pandas`
- `openpyxl` — `pip install openpyxl`
- `jupyter` — `pip install notebook` *(for the notebook only)*
