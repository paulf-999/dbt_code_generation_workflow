{{-
    config(
        schema='incremental',
        materialized='incremental',
        on_schema_change='append_new_columns'
    )
-}}

SELECT *
FROM {{ ref('table_b_snapshot') }}

{%- if is_incremental() %}
  -- this filter will only be applied on an incremental run
  WHERE landed_timestamp > (
    SELECT MAX(landed_timestamp)
    FROM {{ this }}
  )
{%- endif %}
