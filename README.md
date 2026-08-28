# Retail Sales Data Pipeline & Dashboard

I built this project to practice taking messy, real-world data all the way from a raw CSV to an actual dashboard someone could use to make decisions. It uses a real online retail transactions dataset (~541K rows) — I cleaned it in Python, loaded it into MySQL, wrote SQL to answer a bunch of business questions, and then built a Metabase dashboard on top of it.

## What this project does

1. Cleans and transforms the raw data with Python (Pandas)
2. Loads the cleaned data into a MySQL database with SQLAlchemy
3. Uses SQL to dig into revenue trends, customer behavior, and product performance
4. Visualizes all of it in an interactive Metabase dashboard

## Tools I used

- **Python (Pandas)** — cleaning and transforming the raw data
- **SQLAlchemy** — connecting Python to MySQL and loading the data in
- **MySQL** — storing and querying the transaction data
- **SQL** — window functions, CTEs, subqueries for the actual analysis
- **Metabase** — building the dashboard

## How I built it

### 1. Cleaning the data (`sql_python.py`)
The raw CSV had over 541K rows and needed some work before it was usable:
- Loaded it with `latin-1` encoding since the default UTF-8 threw errors
- Cleaned up messy text fields (`InvoiceNo`, `StockCode`, `Description`, `Country`) — stripping whitespace and extra spaces
- Fixed the data types: `InvoiceDate` to datetime, `Quantity` to int, `UnitPrice` to float, and `CustomerID` to a nullable integer (`Int64`) so I didn't lose rows that were missing a customer ID
- Checked everything before loading it — null counts, cancelled orders, date range — just to make sure nothing looked off
- Pushed the cleaned data into MySQL with SQLAlchemy's `to_sql`

### 2. Analyzing it with SQL (`SQL_Retail_Store.sql`)
Once the data was in MySQL, I wrote queries to answer questions like:
- How many orders, customers, and how much total revenue?
- What are the top 10 products by quantity sold?
- Which countries bring in the most revenue?
- How does revenue change month to month, and what's the growth rate? (used `LAG()` for this)
- What's the average order value?
- How do products rank by revenue? (`RANK()`)
- Who are the one-time, regular, and loyal customers?
- What's the repeat purchase rate?
- Which products tend to get bought together?
- Does revenue vary by day of the week?

### 3. Building the dashboard
I connected those SQL queries to Metabase to pull everything together into one dashboard — revenue, customers, and product performance all in one place.

## What I found

- **Total revenue** came out to around $10.6M over the dataset's date range (Dec 2010 – Dec 2011)
- **65.57%** of customers made more than one order — a solid repeat purchase rate
- Customers broke down into **1,972 regular, 1,087 loyal, and 1,313 one-time** buyers
- The **UK dominates revenue** at about 84.6% of the total — makes sense given the dataset
- There's a clear **revenue spike heading into November**, which tracks with holiday shopping season
- **Tuesdays and Thursdays** are the strongest revenue days, **Sundays** the weakest

## Dashboard

![Retail Store Dashboard](dashboard_overview.png)
![Revenue by Day of Week](revenue_by_day.png)

## Repository Structure

```
retail-sales-data-pipeline/
│
├── sql_python.py            # Python script: clean data and load into MySQL
├── SQL_Retail_Store.sql     # SQL queries for business analysis
├── dashboard_overview.png   # Metabase dashboard screenshot
├── revenue_by_day.png       # Metabase dashboard screenshot
├── requirements.txt         # Python dependencies
└── README.md
```

## Want to run it yourself?

1. Clone the repo and install what you need:
   ```
   pip install -r requirements.txt
   ```
2. Set up a MySQL database and point `sql_python.py` at it (see the note below on credentials).
3. Update the `file_path` in `sql_python.py` to wherever your CSV lives.
4. Run it:
   ```
   python sql_python.py
   ```
5. Run the queries in `SQL_Retail_Store.sql` against the `online_retail` table.
6. Connect Metabase to your MySQL database and rebuild the dashboard from there.

> **Quick note on credentials:** don't commit real database credentials in the connection string. I use environment variables instead:
> ```python
> import os
> engine = create_engine(os.environ["DATABASE_URL"])
> ```

## What I'd add next

- Automate the pipeline with something like Airflow so it runs on a schedule instead of manually
- Add basic data validation tests (`pytest` or `Great Expectations`)
- Build out cohort/retention analysis over time
- Add a customer lifetime value (CLV) calculation
