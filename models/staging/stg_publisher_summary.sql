with source as (
    select * from {{ ref('publisher_summary') }}
),

publisher_renamed as (
    select 
        publisher,
        publisher_tier,
        publisher_region,
        titles                  as total_titles,
        total_sales_m           as total_sales_million,
        avg_metacritic          as avg_metacritic_score,
        goty_wins               as total_goty_wins,
        avg_revenue_m           as avg_revenue_million,
        pct_sequels             as pct_is_sequel
    from source
    where publisher is not null
)

select * from publisher_renamed