-- Description: Validates the existence of certain columns in a table within the raw database.
-- Args:
-- * schema (string): name of the raw schema
-- * table_list (list): list of tables referenced

{% macro raw_table_existence(schema, table_list) %}

WITH source AS (
    SELECT *
    FROM "{{ env_var('SNOWFLAKE_LOAD_DATABASE') }}".information_schema.tables

)
, counts AS (
    SELECT COUNT(1) AS row_count
    FROM source
    WHERE LOWER(table_schema) = '{{ schema|lower }}'
        AND LOWER(table_name) in (
            {%- for table in table_list -%}
                '{{ table|lower }}'{% if not loop.last %},{%- endif -%}
            {%- endfor -%}
        )
)

SELECT row_count
FROM counts
WHERE row_count < array_size(array_construct(
        {%- for table in table_list -%}
            '{{ table|lower }}'{% if not loop.last %},{%- endif -%}
        {%- endfor -%}
    ))
{% endmacro %}
