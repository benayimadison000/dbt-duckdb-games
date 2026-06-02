{% macro sales_tier(column_name) %}
    case
        when {{ column_name }} >= 10  then 'Blockbuster'
        when {{ column_name }} >= 1   then 'Hit'
        when {{ column_name }} >= 0.1 then 'Moderate'
        else 'Low'
    end
{% endmacro %}