{% snapshot table_a_snapshot %}

{{-
    config(
        target_database='BIKE_SHOP_RAW_DB',
        target_schema='snapshot',
        unique_key='customer_id',

        strategy='timestamp',
        updated_at='landed_timestamp',
        invalidate_hard_deletes=True
    )
-}}
-- note: 'invalidate_hard_deletes' is a dbt opt-in feature
-- it's used to enable invalidating hard deleted records, when performing the snapshot query.

    SELECT *
    FROM {{ source('data_src_a', 'table_a') }}

    {%- if target.name == 'dev' %}{{ limit_row_count(5) }}{%- endif %}

{% endsnapshot %}
