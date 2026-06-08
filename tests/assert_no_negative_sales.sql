-- Fails if any game has negative global sales
-- Returns rows that violate the rule (0 rows = test passes)
select
    game_id,
    title,
    global_sales_million
from {{ ref('mart_game_performance') }}
where global_sales_million < 0