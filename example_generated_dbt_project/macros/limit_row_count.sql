{% macro limit_row_count(row_count) %}
LIMIT {{ row_count }}
{% endmacro %}
