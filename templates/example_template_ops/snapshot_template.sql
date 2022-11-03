{% snapshot <src_tbl_name>_snapshot %}

{{
    config(
        target_database='{{ snowflake_src_db }}',
        target_schema='{{ db_schema_snapshots }}',
        unique_key='{{ primary_key }}',

        strategy='timestamp',
        updated_at='{{ updated_at }}',
        invalidate_hard_deletes=True
    )
}}
-- note: 'invalidate_hard_deletes' is a dbt opt-in feature to enable invalidating hard deleted records, when performing the snapshot query.

SELECT *
FROM {{ source(' <source_name>', ' <src_tbl_name>') }}

{% endsnapshot %}
