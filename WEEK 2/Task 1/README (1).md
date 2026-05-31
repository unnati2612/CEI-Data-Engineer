# Sales Data Analysis - SQL Assignment

This is my SQL assignment where i analyzed a sales dataset using various SQL queries like filtering, grouping, aggregations and some business related queries.

---

## What i did in this assignment

1. Created a table and loaded the sales csv data into it
2. Explored the dataset - checked schema, sample rows, distinct values
3. Used WHERE clause to filter data by region, category, date and sales amount
4. Used GROUP BY to find total sales, quantity and averages
5. Found top products and categories using ORDER BY and LIMIT
6. Wrote queries for real use cases like monthly trends, top customers, duplicate check
7. Validated the data - checked for nulls, negative values, row counts

---

## Dataset

I used a sales dataset which has these columns:

- order_id, order_date
- customer_id, customer_name
- region, category, sub_category, product_name
- quantity, unit_price, discount
- sales, profit

---

## Files in this repo

- `sales_analysis.sql` - all the sql queries i wrote for this assignment
- `data/sales_data.csv` - the dataset i used
- `README.md` - this file

---

## How to run

I used SQLite for this. Steps to run:

```
sqlite3 sales.db
.mode csv
.import data/sales_data.csv sales
.read sales_analysis.sql
```

---

## Queries i wrote

**Exploring data**
- checked total rows, sample data, distinct regions and categories

**Filtering with WHERE**
- filtered by region, category, date range, sales amount
- also combined multiple conditions

**Aggregations**
- total and average sales by region and category
- profit by region and category combined

**Top N results**
- top 10 products by revenue
- top 5 categories by quantity sold
- bottom 5 sub-categories by profit (loss makers)

**Business queries**
- monthly sales trend to see how sales changed over months
- top 10 customers by total spend
- most ordered product
- orders with high discounts and their profit impact
- orders where profit was negative (loss orders)
- duplicate order id check
- each category's % contribution to total sales

**Validation**
- null checks on all important columns
- negative sales check
- min, max, avg stats for sales and profit
- date range of the full dataset

---

## Some insights i found

- West region had the highest total sales
- Technology category was the most profitable
- Some orders with high discounts ended up in loss
- A few duplicate order ids were found which shows some data quality issues

---

## Tools used

- SQLite
- DB Browser for SQLite (to view results)

---


