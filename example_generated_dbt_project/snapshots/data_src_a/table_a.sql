{% snapshot table_a_snapshot %}

{{
    config(
        target_database='_dev',
        target_schema='snapshot',
        unique_key='customer_id',

        strategy='timestamp',
        updated_at='landed_timestamp',
        invalidate_hard_deletes=True
    )
}}

-- note: 'invalidate_hard_deletes' is a dbt opt-in feature to enable invalidating hard deleted records, when performing the snapshot query.

SELECT *
FROM {{ source('data_src_a', 'table_a') }}
LIMIT 5

{% endsnapshot %}
