-- Description: Validates the existence of certain columns in a table within the raw database.
-- Args:
-- * schema (string): name of the raw schema
-- * table_list (list): list of tables referenced

{% test raw_table_existence(schema, model) %}

WITH counts AS (
    SELECT COUNT(1) as row_count
    FROM {{ model['database'] }}.information_schema.tables
    WHERE LOWER(table_schema) = {{ model['schema'] }}
        AND LOWER(table_name) = {{ model['table'] }}

)

SELECT row_count
FROM counts
WHERE row_count < 1

{% endtest %}
