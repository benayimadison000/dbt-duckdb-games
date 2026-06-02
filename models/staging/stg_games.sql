with source AS ( 
    
    select * from {{ ref('games') }}

),
renamed AS (
    Select 
        game_id,
        title,
        platform,
        platform_type,
        platform_maker,
        platform_generation,
        genre,
        cast(year as integer) as release_year,
        publisher,
        developer,
        publisher_region,
        publisher_tier,
        esrb_rating,
        cast(metacritic_score as integer)               as metacritic_score,
        cast(user_score as decimal(4,1))                as user_score,
        cast(critic_review_count as integer)            as critic_review_count,
        cast(user_review_count as integer)              as user_review_count,
        cast(na_sales_million as decimal(10,2))         as na_sales_million,
        cast(eu_sales_million as decimal(10,2))         as eu_sales_million,
        cast(jp_sales_million as decimal(10,2))         as jp_sales_million,
        cast(other_sales_million as decimal(10,2))      as other_sales_million,
        cast(global_sales_million as decimal(10,2))     as global_sales_million,
        cast(estimated_revenue_million_usd as decimal(10,2)) as estimated_revenue_million_usd,
        cast(launch_price_usd as decimal(8,2))          as launch_price_usd,
        cast(is_sequel as boolean)                      as is_sequel,
        cast(online_multiplayer as boolean)             as online_multiplayer,
        cast(dlc_released as boolean)                   as dlc_released,
        cast(microtransactions as boolean)              as microtransactions,
        cast(loot_boxes as boolean)                     as loot_boxes,
        cast(game_pass_available as boolean)            as game_pass_available,
        cast(vr_support as boolean)                     as vr_support,
        cast(goty_nominated as boolean)                 as goty_nominated,
        cast(goty_won as boolean)                       as goty_won,
        cast(how_long_to_beat_main_hrs as decimal(6,1))          as how_long_to_beat_main_hrs,
        cast(how_long_to_beat_completionist_hrs as decimal(6,1)) as how_long_to_beat_completionist_hrs


    FROM source
    where title is not null
)
select *  from renamed