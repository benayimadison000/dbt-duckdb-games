with date_spine as (
    select * from {{ ref('int_date_spine') }}
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

yearly as (
    select * from {{ ref('stg_yearly_trends') }}
),

joined as (
    select
        -- Use date spine as the base so no years are missing
        d.release_year,
        d.decade,
        d.years_since_1980,

        -- Volume (null if no games that year)
        coalesce(g.total_games, 0)              as total_games,
        y.total_titles_released,

        -- Sales
        coalesce(g.total_sales_million, 0)      as total_sales_million,
        coalesce(g.avg_sales_per_game, 0)       as avg_sales_per_game,
        coalesce(g.total_revenue_million, 0)    as total_revenue_million,

        -- Scores
        g.avg_metacritic_score,
        y.avg_user_score,

        -- Pricing
        g.avg_launch_price_usd,

        -- Features
        coalesce(g.pct_sequels, 0)              as pct_sequels,
        coalesce(g.pct_online_multiplayer, 0)   as pct_online_multiplayer,
        coalesce(g.pct_has_dlc, 0)              as pct_has_dlc,
        coalesce(g.pct_microtransactions, 0)    as pct_microtransactions,
        coalesce(g.pct_goty_nominated, 0)       as pct_goty_nominated,
        coalesce(g.total_goty_wins, 0)          as total_goty_wins,

        -- Year tier
        case
            when coalesce(g.total_sales_million, 0) >= 2000 then 'Peak Year'
            when coalesce(g.total_sales_million, 0) >= 1000 then 'Strong Year'
            when coalesce(g.total_sales_million, 0) >= 500  then 'Average Year'
            else 'Slow Year'
        end                                     as year_sales_tier,

        -- Year over year sales change
        coalesce(g.total_sales_million, 0) - lag(coalesce(g.total_sales_million, 0))
            over (order by d.release_year)      as yoy_sales_change_million

    from date_spine d
    left join games g       on d.release_year = g.release_year
    left join yearly y      on d.release_year = y.release_year
)

select * from joined
order by release_year