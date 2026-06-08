# Great choice — snapshots are one of the most important patterns to understand for real data engineering work.
# Let's explore the snapshot we just created. Run explore.py to see the new snap_publishers table and its contents:
# What is SCD Type 2 and Why Does It Matter
# SCD stands for Slowly Changing Dimension. It solves this problem:
# Imagine a publisher changes their tier from Indie to AAA in 2024. Without snapshots:

import duckdb

con = duckdb.connect(r'C:\Data-eng-projects\dbt-projects\dbt-project-1\my_project_1\dev.duckdb')

print("=== SNAPSHOT COLUMNS ===")
result = con.execute('DESCRIBE snapshots.snap_publishers').fetchall()
for row in result:
    print(row)

print("\n=== SNAPSHOT SAMPLE ===")
result = con.execute('''
    SELECT 
        publisher,
        publisher_tier,
        publisher_region,
        dbt_scd_id,
        dbt_updated_at,
        dbt_valid_from,
        dbt_valid_to
    FROM snapshots.snap_publishers
    LIMIT 3
''').fetchall()
for row in result:
    print(row)

print("\n=== TOTAL ROWS ===")
result = con.execute('SELECT COUNT(*) FROM snapshots.snap_publishers').fetchone()
print(f"Total rows: {result[0]}")