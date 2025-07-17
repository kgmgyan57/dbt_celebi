{{
    config(
        schema = "stg_facts",
        materialized = "incremental",
        incremental_startegy='merge',
        unique_key=['unique_key'],
        partition_by={
            "field": "trip_start_timestamp",
            "data_type": "timestamp",
            "granularity": "month"
        },
        cluster_by = "company",
        author = "@gyan",
        tags = ["fact_trips_archive"],
        merge_exclude_columns = ['dbt_created_at'],
        on_schema_change = "append_new_columns",
    )
}}

{% if is_incremental() %}
    {% set max_timestamp = get_max_timestamp(last_updated_at='trip_start_timestamp') %}
{% endif %}


select *,
timestamp(format_timestamp('%Y-%m-%d %H:%M:%S', current_timestamp())) as dbt_created_at,
timestamp(format_timestamp('%Y-%m-%d %H:%M:%S', current_timestamp())) as dbt_updated_at,
from {{ ref('stg__taxi_trips_raw') }}
where 1=1
{% if is_incremental() %}
and (
timestamp_trunc(trip_start_timestamp, month) >= cast('{{ max_timestamp }}' as timestamp)
and timestamp_trunc(trip_start_timestamp, month) < cast(timestamp_trunc(date_sub(current_date(), interval 5 year), month) as timestamp)
)
{% else %}
and timestamp_trunc(trip_start_timestamp, month) < cast(timestamp_trunc(date_sub(current_date(), interval 5 year), month) as timestamp)
{% endif %}