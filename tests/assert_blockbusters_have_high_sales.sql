-- Fails if any Blockbuster tier game has sales below 10 million
-- Validates that the sales_tier macro logic is correct
select
    game_id,
    title,
    global_sales_million,
    sales_tier
from {{ ref('mart_game_performance') }}
where sales_tier = 'Blockbuster'
and global_sales_million < 10