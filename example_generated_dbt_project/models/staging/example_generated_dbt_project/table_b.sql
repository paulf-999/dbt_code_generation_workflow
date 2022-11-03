{{
    config(
        materialized='incremental'
    )
}}

SELECT *
FROM {{ ref('table_b_snapshot') }}

{% if is_incremental() %}

  -- this filter will only be applied on an incremental run
  where landed_timestamp > (SELECT MAX(landed_timestamp) FROM {{ this }})

{% endif %}
