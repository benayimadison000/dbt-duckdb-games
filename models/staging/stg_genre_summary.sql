with source AS (
    select * from {{ ref('genre_summary') }}
),

summary_renamed AS (
    Select 
        genre,
        titles                  as total_titles,
        total_sales_m           as total_sales_million,
        avg_sales_m             as avg_sales_million,
        avg_metacritic          as avg_metacritic_score,
        avg_user_score          as avg_user_score,
        pct_goty_nominated      as pct_goty_nominated,
        avg_htlb_main           as avg_hours_to_beat_main,
        pct_online              as pct_online_multiplayer,
        pct_dlc                 as pct_has_dlc,
        pct_microtransactions   as pct_has_microtransactions
    FROM source
    where genre is not null
)
select * from summary_renamed