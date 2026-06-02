{% macro critic_tier(column_name) %}
    case
        when {{ column_name }} >= 90 then 'Must Play'
        when {{ column_name }} >= 75 then 'Good'
        when {{ column_name }} >= 60 then 'Mixed'
        when {{ column_name }} is not null then 'Poor'
        else 'Unscored'
    end
{% endmacro %}