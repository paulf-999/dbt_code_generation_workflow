-- Description:
-- * Performs a rowcount check and fails if there are fewer rows than expected
-- * An optional condition can be applied as well
-- * This is for a source reference as defined in a sources.yml file

-- Args:
-- * table (string): name of table
-- * count (int): minimum number of rows expected in source
-- * where_clause (string - optional): Optional filter on the data. Wrap the entire clause in double quotes.

{% macro source_rowcount(source_name, table, count, where_clause=None) %}

WITH source AS (
    SELECT *
    FROM {{ source(source_name, table) }}
)
, counts AS (

    SELECT COUNT(*) AS row_count
    FROM source
    {% if where_clause != None %}
        WHERE {{ where_clause }}
    {% endif %}

)

SELECT row_count
FROM counts
WHERE row_count < {{ count }}

{% endmacro %}
