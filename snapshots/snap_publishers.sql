{% snapshot snap_publishers %}

{{
    config(
        target_schema='snapshots',
        unique_key='publisher',
        strategy='check',
        check_cols=['publisher_tier', 'publisher_region'],
    )
}}

select
    publisher,
    publisher_tier,
    publisher_region,
    total_titles,
    total_sales_million,
    avg_metacritic_score,
    total_goty_wins,
    avg_revenue_million,
    pct_is_sequel
from {{ ref('stg_publisher_summary') }}

{% endsnapshot %}



-- target_schema='snapshots'  → writes to main_snapshots in DuckDB
-- unique_key='publisher'     → one row per publisher to track
-- strategy='check'           → take a snapshot when checked columns change
-- check_cols=[...]           → only trigger a new snapshot row when
--                              publisher_tier or publisher_region changes