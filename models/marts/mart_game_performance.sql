with games as (
    select * from {{ ref('int_games_enriched') }}
),

final as (
    select
        -- Identity
        game_id,
        title,
        release_year,
        platform,
        platform_type,
        platform_maker,
        genre,
        publisher,
        publisher_tier,
        publisher_region,
        esrb_rating,
        launch_price_usd,

        -- Sales performance
        global_sales_million,
        na_sales_million,
        eu_sales_million,
        jp_sales_million,
        other_sales_million,
        estimated_revenue_million_usd,

        -- Score performance
        metacritic_score,
        user_score,
        critic_review_count,
        user_review_count,

        -- Score vs genre average
        metacritic_score - genre_avg_metacritic       as metacritic_vs_genre_avg,
        global_sales_million - genre_avg_sales_million as sales_vs_genre_avg,

        -- Completion
        how_long_to_beat_main_hrs,
        how_long_to_beat_completionist_hrs,

        -- Features
        is_sequel,
        online_multiplayer,
        dlc_released,
        microtransactions,
        loot_boxes,
        game_pass_available,
        vr_support,
        goty_nominated,
        goty_won,

        -- Derived tiers

    
        --case
        --    when global_sales_million >= 10  then 'Blockbuster'
        --    when global_sales_million >= 1   then 'Hit'
        --    when global_sales_million >= 0.1 then 'Moderate'
        --    else 'Low'
        --end as sales_tier,

        -- Derived tiers
        {{ sales_tier('global_sales_million') }}  as sales_tier,
        {{ critic_tier('metacritic_score') }}     as critic_tier

        -- case
        --     when metacritic_score >= 90 then 'Must Play'
        --     when metacritic_score >= 75 then 'Good'
        --     when metacritic_score >= 60 then 'Mixed'
        --     when metacritic_score is not null then 'Poor'
        --     else 'Unscored'
        -- end as critic_tier

    from games
)

select * from final