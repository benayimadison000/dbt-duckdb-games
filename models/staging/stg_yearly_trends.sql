with source as (
    select * from {{ ref('yearly_trends') }}
),

yearly_trends_renamed as (
    select
        cast(year as integer)       as release_year,
        titles_released             as total_titles_released,
        total_sales_m               as total_sales_million,
        avg_metacritic              as avg_metacritic_score,
        avg_user_score              as avg_user_score,
        pct_online                  as pct_online_multiplayer,
        pct_microtransactions       as pct_has_microtransactions,
        pct_dlc                     as pct_has_dlc,
        avg_launch_price            as avg_launch_price_usd,
        goty_games                  as total_goty_games,
        avg_htlb                    as avg_hours_to_beat
    from source
    where year is not null
)

select * from yearly_trends_renamed