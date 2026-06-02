import duckdb

con = duckdb.connect(r'C:\Data-eng-projects\dbt-projects\dbt-project-1\my_project_1\dev.duckdb')

print("=== DATE SPINE SAMPLE ===")
result = con.execute('''
    SELECT *
    FROM main_intermediate.int_date_spine
    ORDER BY release_year
    LIMIT 10
''').fetchall()

for row in result:
    print(row)

print("\n=== DATE SPINE TOTAL ROWS ===")
result = con.execute('''
    SELECT COUNT(*) as total_years
    FROM main_intermediate.int_date_spine
''').fetchone()
print(f"Total years: {result[0]}")