{{
    config(
        materialized='incremental',
        unique_key='game_id',
        on_schema_change='sync_all_columns'
    )
}}

with games as (
    select * from {{ ref('int_games_enriched') }}

    {% if is_incremental() %}
    -- On incremental runs, only process games not already in the table
    where game_id not in (select game_id from {{ this }})
    {% endif %}
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


        {{ sales_tier('global_sales_million') }}  as sales_tier,
        {{ critic_tier('metacritic_score') }}     as critic_tier



    from games
)

select * from final