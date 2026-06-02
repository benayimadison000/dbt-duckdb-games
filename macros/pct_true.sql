{% macro pct_true(column_name) %}
    round(avg(case when {{ column_name }} then 1.0 else 0.0 end) * 100, 1)
{% endmacro %}