with games as (
    select * from {{ ref('int_games_enriched') }}
),

publisher_stats as (
    select
        publisher,
        publisher_tier,
        publisher_region,

        -- Volume
        count(game_id)                                as total_games,
        count(distinct genre)                         as genres_covered,
        count(distinct platform)                      as platforms_covered,
        min(release_year)                             as first_release_year,
        max(release_year)                             as latest_release_year,

        -- Sales
        round(sum(global_sales_million), 2)           as total_sales_million,
        round(avg(global_sales_million), 2)           as avg_sales_per_game,
        round(max(global_sales_million), 2)           as best_game_sales,

        -- Revenue
        round(sum(estimated_revenue_million_usd), 2)  as total_revenue_million,
        round(avg(estimated_revenue_million_usd), 2)  as avg_revenue_per_game,

        -- Quality
        round(avg(metacritic_score), 1)               as avg_metacritic_score,
        round(avg(user_score), 1)                     as avg_user_score,
        count(case when metacritic_score >= 90
              then 1 end)                             as games_scored_90_plus,

        -- Awards
        count(case when goty_nominated
              then 1 end)                             as goty_nominations,
        count(case when goty_won
              then 1 end)                             as goty_wins,

        -- Pricing
        round(avg(launch_price_usd), 2)               as avg_launch_price_usd,

        -- Monetisation strategy
        -- round(avg(case when microtransactions
        --       then 1.0 else 0.0 end) * 100, 1)        as pct_microtransactions,
        -- round(avg(case when dlc_released
        --       then 1.0 else 0.0 end) * 100, 1)        as pct_has_dlc,
        -- round(avg(case when is_sequel
        --       then 1.0 else 0.0 end) * 100, 1)        as pct_sequels,
        -- round(avg(case when game_pass_available
        --       then 1.0 else 0.0 end) * 100, 1)        as pct_on_game_pass,

        {{ pct_true('microtransactions') }}   as pct_microtransactions,
        {{ pct_true('dlc_released') }}        as pct_has_dlc,
        {{ pct_true('is_sequel') }}           as pct_sequels,
        {{ pct_true('game_pass_available') }} as pct_on_game_pass,

        -- Regional strength
        round(sum(na_sales_million), 2)               as total_na_sales_million,
        round(sum(eu_sales_million), 2)               as total_eu_sales_million,
        round(sum(jp_sales_million), 2)               as total_jp_sales_million,

        -- Publisher rank by total sales
        rank() over (
            order by sum(global_sales_million) desc
        )                                             as sales_rank,

        -- Publisher rank within their tier
        rank() over (
            partition by publisher_tier
            order by sum(global_sales_million) desc
        )                                             as sales_rank_within_tier

    from games
    group by publisher, publisher_tier, publisher_region
)

select * from publisher_stats
order by sales_rank