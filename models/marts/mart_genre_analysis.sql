with games as (
    select * from {{ ref('int_games_enriched') }}
),

genre_stats as (
    select
        genre,

        -- Volume
        count(game_id)                              as total_games,
        count(distinct publisher)                   as total_publishers,
        count(distinct platform)                    as total_platforms,

        -- Sales
        round(sum(global_sales_million), 2)         as total_sales_million,
        round(avg(global_sales_million), 2)         as avg_sales_million,
        round(max(global_sales_million), 2)         as best_selling_game_sales,

        -- Revenue
        round(sum(estimated_revenue_million_usd), 2)  as total_revenue_million,
        round(avg(estimated_revenue_million_usd), 2)  as avg_revenue_million,

        -- Scores
        round(avg(metacritic_score), 1)             as avg_metacritic_score,
        round(avg(user_score), 1)                   as avg_user_score,

        -- Pricing
        round(avg(launch_price_usd), 2)             as avg_launch_price_usd,

        -- Completion time
        round(avg(how_long_to_beat_main_hrs), 1)    as avg_hours_to_beat,

        -- Feature rates
        --round(avg(case when is_sequel           then 1.0 else 0.0 end) * 100, 1) as pct_sequels,
        --round(avg(case when online_multiplayer  then 1.0 else 0.0 end) * 100, 1) as pct_online_multiplayer,
        --round(avg(case when dlc_released        then 1.0 else 0.0 end) * 100, 1) as pct_has_dlc,
        --round(avg(case when microtransactions   then 1.0 else 0.0 end) * 100, 1) as pct_microtransactions,
        --round(avg(case when goty_nominated      then 1.0 else 0.0 end) * 100, 1) as pct_goty_nominated,
        --round(avg(case when goty_won            then 1.0 else 0.0 end) * 100, 1) as pct_goty_won,

        {{ pct_true('is_sequel') }}           as pct_sequels,
        {{ pct_true('online_multiplayer') }}  as pct_online_multiplayer,
        {{ pct_true('dlc_released') }}        as pct_has_dlc,
        {{ pct_true('microtransactions') }}   as pct_has_microtransactions,
        {{ pct_true('goty_nominated') }}      as pct_goty_nominated,
        {{ pct_true('goty_won') }}            as pct_goty_won,

        -- Regional sales split
        round(avg(na_sales_million), 2)             as avg_na_sales_million,
        round(avg(eu_sales_million), 2)             as avg_eu_sales_million,
        round(avg(jp_sales_million), 2)             as avg_jp_sales_million,

        -- Genre tier based on total sales
        case
            when sum(global_sales_million) >= 5000 then 'Tier 1'
            when sum(global_sales_million) >= 1000 then 'Tier 2'
            when sum(global_sales_million) >= 500  then 'Tier 3'
            else 'Tier 4'
        end as genre_sales_tier

    from games
    group by genre
)

select * from genre_stats
order by total_sales_million desc