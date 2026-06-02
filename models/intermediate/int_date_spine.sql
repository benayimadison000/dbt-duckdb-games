{{
    config(materialized='table')
}}

with final as (
    select
        extract(year from spine.date_year)::integer             as release_year,
        extract(year from spine.date_year)::integer - 1980      as years_since_1980,
        case
            when extract(year from spine.date_year)::integer between 1980 and 1989 then '1980s'
            when extract(year from spine.date_year)::integer between 1990 and 1999 then '1990s'
            when extract(year from spine.date_year)::integer between 2000 and 2009 then '2000s'
            when extract(year from spine.date_year)::integer between 2010 and 2019 then '2010s'
            else '2020s'
        end                                                     as decade
    from (
        {{ dbt_utils.date_spine(
            datepart="year",
            start_date="cast('1980-01-01' as date)",
            end_date="cast('2030-01-01' as date)"
        ) }}
    ) as spine
)

select * from final