-- Description: Validates the existence of a table within the raw database.
-- Args:
-- * schema (string): name of the raw schema
-- * table_list (list): list of tables referenced

{% test is_table_empty(model) %}

WITH counts AS (
    SELECT COUNT(*) AS row_count
    FROM {{ model['table'] }}
)

SELECT row_count
FROM counts
WHERE row_count < 1

{% endtest %}
