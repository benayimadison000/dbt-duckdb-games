# Then update explore.py to check what happened to Sega:
# Let's see SCD Type 2 in action. We'll manually update a publisher's tier in the seed data to simulate what happens when source data changes.
# Open seeds/publisher_summary.csv in VS Code and find the row for Sega. Change their publisher_tier from AAA to Indie.
# Save the file, then reload the seeds and run the snapshot:
# dbt seed
# dbt snapshot
# Then update explore.py to check what happened to Sega:

import duckdb

con = duckdb.connect(r'C:\Data-eng-projects\dbt-projects\dbt-project-1\my_project_1\dev.duckdb')

print("=== SEGA HISTORY ===")
result = con.execute('''
    SELECT
        publisher,
        publisher_tier,
        publisher_region,
        dbt_valid_from,
        dbt_valid_to
    FROM snapshots.snap_publishers
    WHERE publisher = 'Sega'
    ORDER BY dbt_valid_from
''').fetchall()
for row in result:
    print(row)

print("\n=== TOTAL ROWS (should be 52 now) ===")
result = con.execute('SELECT COUNT(*) FROM snapshots.snap_publishers').fetchone()
print(f"Total rows: {result[0]}")