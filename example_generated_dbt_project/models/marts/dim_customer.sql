---------------------------------------------------------------------
-- Import CTEs
---------------------------------------------------------------------
WITH base_<entity> AS (
    SELECT *
    FROM {{ source('DATA_SRC', '') }}
)

WITH base_<entity2> AS (
    SELECT *
    FROM {{ source('DATA_SRC', '') }}
)

---------------------------------------------------------------------
-- Logical CTEs
---------------------------------------------------------------------
, <entity> AS (
    SELECT
        ...
    FROM base_<entity>
)

, <entity_2> AS (
    SELECT
        ...
    FROM base_<entity2>
)

---------------------------------------------------------------------
-- Final CTE
---------------------------------------------------------------------
, final_cte AS (
    SELECT
        ...
    FROM entity1
        LEFT JOIN entity2
        ON entity2.<entity>_id = entity1.<entity>_id;
)

-- re-order/group the columns
SELECT
    -- primary data: id's & business keys
    <entity>_id
    , <entity_key

    -- metadata: e.g., 'created_at', 'updated_at' fields
FROM final_cte
