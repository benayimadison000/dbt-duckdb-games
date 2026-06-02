with source as (
    select * from {{ ref('platform_summary') }}
),

platform_renamed as (
    select 
        platform,
        platform_type,
        platform_maker,
        titles                  as total_titles,
        total_sales_m           as total_sales_million,
        avg_metacritic          as avg_metacritic_score,
        avg_user_score          as avg_user_score,
        top_genre               as top_genre,
        avg_launch_price        as avg_launch_price_usd
    from source
    where platform is not null
)

select * from platform_renamed