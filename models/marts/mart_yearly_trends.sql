with yearly as (
    select * from {{ ref('stg_yearly_trends') }}
),

games as (
    select
        release_year,
        count(game_id)                                as total_games,
        round(sum(global_sales_million), 2)           as total_sales_million,
        round(avg(global_sales_million), 2)           as avg_sales_per_game,
        round(sum(estimated_revenue_million_usd), 2)  as total_revenue_million,
        round(avg(metacritic_score), 1)               as avg_metacritic_score,
        round(avg(launch_price_usd), 2)               as avg_launch_price_usd,
        {{ pct_true('is_sequel') }}                   as pct_sequels,
        {{ pct_true('online_multiplayer') }}          as pct_online_multiplayer,
        {{ pct_true('dlc_released') }}                as pct_has_dlc,
        {{ pct_true('microtransactions') }}           as pct_microtransactions,
        {{ pct_true('goty_nominated') }}              as pct_goty_nominated,
        count(case when goty_won then 1 end)          as total_goty_wins
    from {{ ref('int_games_enriched') }}
    group by release_year
),

joined as (
    select
        g.release_year,

        -- Volume
        g.total_games,
        y.total_titles_released,

        -- Sales
        g.total_sales_million,
        g.avg_sales_per_game,
        g.total_revenue_million,

        -- Scores
        g.avg_metacritic_score,
        y.avg_user_score,

        -- Pricing
        g.avg_launch_price_usd,
        y.avg_launch_price_usd          as source_avg_launch_price_usd,

        -- Features
        g.pct_sequels,
        g.pct_online_multiplayer,
        g.pct_has_dlc,
        g.pct_microtransactions,
        g.pct_goty_nominated,
        g.total_goty_wins,

        -- Year tier based on total sales
        case
            when g.total_sales_million >= 2000 then 'Peak Year'
            when g.total_sales_million >= 1000 then 'Strong Year'
            when g.total_sales_million >= 500  then 'Average Year'
            else 'Slow Year'
        end                             as year_sales_tier,

        -- Year over year sales change
        g.total_sales_million - lag(g.total_sales_million)
            over (order by g.release_year) as yoy_sales_change_million

    from games g
    left join yearly y on g.release_year = y.release_year
)

select * from joined
order by release_year