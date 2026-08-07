```python
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import pandas as pd
from sqlalchemy import create_engine


# =========================================================
# 1. CONNECT PYTHON TO MYSQL
# =========================================================
from sqlalchemy import create_engine

engine = create_engine(
    "mysql+pymysql://root:password@localhost:3306/ecommerce?charset=utf8mb4"
)

with engine.connect() as connection:
    print("Connected successfully!")

# =========================================================
# 2. LOAD THE ORIGINAL CSV
# =========================================================

file_path = "/Users/aseelali/Desktop/csv/retail_records.csv"

df = pd.read_csv(
    file_path,
    encoding="latin-1",
    dtype=str
)

print("CSV loaded successfully.")
print("Original rows:", len(df))


# =========================================================
# 3. CLEAN TEXT COLUMNS
# =========================================================

for col in ["InvoiceNo", "StockCode", "Description", "Country"]:

    df[col] = (
        df[col]
        .str.strip()
        .str.replace(r"\s+", " ", regex=True)
    )


# =========================================================
# 4. CONVERT DATA TYPES
# =========================================================

# Convert InvoiceDate from TEXT to DATETIME
df["InvoiceDate"] = pd.to_datetime(
    df["InvoiceDate"],
    format="%m/%d/%y %H:%M"
)

# Convert Quantity from TEXT to INTEGER
df["Quantity"] = df["Quantity"].astype(int)

# Convert UnitPrice from TEXT to FLOAT
df["UnitPrice"] = (
    df["UnitPrice"]
    .astype(float)
    .round(2)
)

# Convert CustomerID to INTEGER
# Int64 allows missing values (NULL)
df["CustomerID"] = df["CustomerID"].astype("Int64")


# =========================================================
# 5. CHECK THE CLEANED DATA
# =========================================================

print("\nFirst 5 rows:")
print(df.head())

print("\nData types:")
print(df.dtypes)

print("\nRows:", len(df))

print(
    "Null CustomerID:",
    df["CustomerID"].isna().sum()
)

print(
    "Null Description:",
    df["Description"].isna().sum()
)

print(
    "Cancellations:",
    df["InvoiceNo"].str.startswith("C", na=False).sum()
)

print(
    "Date range:",
    df["InvoiceDate"].min(),
    "to",
    df["InvoiceDate"].max()
)


# =========================================================
# 6. SAVE A CLEANED CSV (OPTIONAL)
# =========================================================

clean_file_path = (
    "/Users/aseelali/Desktop/csv/retail_records_clean.csv"
)

df.to_csv(
    clean_file_path,
    index=False,
    encoding="utf-8",
    na_rep="\\N"
)

print("\nCleaned CSV saved successfully.")


# =========================================================
# 7. SEND DATA FROM PYTHON TO MYSQL
# =========================================================

df.to_sql(
    "online_retail",
    con=engine,
    if_exists="replace",
    index=False
)

print("\nData successfully uploaded to MySQL!")


# =========================================================
# 8. VERIFY THE MYSQL TABLE
# =========================================================

with engine.connect() as connection:

    result = connection.exec_driver_sql(
        "SELECT COUNT(*) AS total_rows FROM online_retail"
    )

    total_rows = result.fetchone()[0]

    print(
        "Rows in MySQL online_retail table:",
        total_rows
    )
```
