-- Description: Validates the existence of a table within the raw database.
-- Args:
-- * schema (string): name of the raw schema
-- * table_list (list): list of tables referenced

{% test raw_table_existence(model) %}

WITH source AS (
    SELECT *
    FROM {{ model['database'] }}.information_schema.tables

)
, counts AS (
    SELECT row_count
    FROM source
    WHERE LOWER(table_schema) = '{{ model['schema']|lower }}'
        AND LOWER(table_name) = '{{ model['table']|lower }}'
)

SELECT row_count
FROM counts
WHERE row_count = 0
{% endtest %}
