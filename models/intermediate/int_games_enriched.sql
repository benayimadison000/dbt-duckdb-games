with games as (
    select * from {{ ref('stg_games') }}
),

genre as (
    select * from {{ ref('stg_genre_summary') }}
),

platform as (
    select * from {{ ref('stg_platform_summary') }}
),

publisher as (
    select * from {{ ref('stg_publisher_summary') }}
),

enriched as (
    select
        -- Game core fields
        g.game_id,
        g.title,
        g.release_year,
        g.esrb_rating,
        g.launch_price_usd,

        -- Platform context
        g.platform,
        g.platform_type,
        g.platform_maker,
        g.platform_generation,
        p.total_titles          as platform_total_titles,
        p.total_sales_million   as platform_total_sales_million,

        -- Genre context
        g.genre,
        ge.total_titles         as genre_total_titles,
        ge.avg_sales_million    as genre_avg_sales_million,
        ge.avg_metacritic_score as genre_avg_metacritic,

        -- Publisher context
        g.publisher,
        g.publisher_tier,
        g.publisher_region,
        pu.total_titles         as publisher_total_titles,
        pu.total_goty_wins      as publisher_goty_wins,

        -- Sales
        g.na_sales_million,
        g.eu_sales_million,
        g.jp_sales_million,
        g.other_sales_million,
        g.global_sales_million,
        g.estimated_revenue_million_usd,

        -- Scores
        g.metacritic_score,
        g.user_score,
        g.critic_review_count,
        g.user_review_count,

        -- Game features
        g.is_sequel,
        g.online_multiplayer,
        g.dlc_released,
        g.microtransactions,
        g.loot_boxes,
        g.game_pass_available,
        g.vr_support,
        g.goty_nominated,
        g.goty_won,
        g.how_long_to_beat_main_hrs,
        g.how_long_to_beat_completionist_hrs

    from games g
    left join genre ge       on g.genre = ge.genre
    left join platform p     on g.platform = p.platform
    left join publisher pu   on g.publisher = pu.publisher
)

select * from enriched