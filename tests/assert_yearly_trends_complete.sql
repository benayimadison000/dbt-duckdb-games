-- Fails if any year between 1980 and 2029 is missing from the trends mart
-- Validates the date spine is working correctly
select spine.release_year
from {{ ref('int_date_spine') }} spine
left join {{ ref('mart_yearly_trends') }} trends
    on spine.release_year = trends.release_year
where trends.release_year is null