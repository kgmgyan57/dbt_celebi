{{
    config(
        schema = "facts",
        materialized = "incremental",
        incremental_startegy='merge',
        unique_key=['unique_key'],
        partition_by={
            "field": "trip_start_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by = "company",
        author = "@gyan",
        tags = ["fact_trips", "taxi_trips"],
        merge_exclude_columns = ['dbt_created_at'],
        on_schema_change = "append_new_columns",
    )
}}

{% if is_incremental() %}
    {% set max_timestamp = get_max_timestamp(last_updated_at='trip_start_date') %}
{% endif %}

select
  cast(unique_key as string) as unique_key,
  cast(taxi_id as string) as taxi_id,
  cast(trip_start_timestamp as timestamp) as trip_start_timestamp,
  cast(trip_end_timestamp as timestamp) as trip_end_timestamp,
  cast(trip_seconds as int64) as trip_seconds,
  cast(trip_miles as float64) as trip_miles,
  cast(coalesce(fare, 0.0) as float64) as fare,
  cast(coalesce(tips, 0.0) as float64) as tips,
  cast(coalesce(tolls, 0.0) as float64) as tolls,
  cast(coalesce(extras, 0.0) as float64) as extras,
  cast(trip_total as float64) as trip_total,
  cast(coalesce(payment_type, 'Others') as string) as payment_type,
  cast(coalesce(company, 'NA') as string) as company,
  cast(trip_start_date as date) as trip_start_date,
  cast(trip_end_date as date) as trip_end_date,
  timestamp(format_timestamp('%Y-%m-%d %H:%M:%S', current_timestamp())) as dbt_created_at,
  timestamp(format_timestamp('%Y-%m-%d %H:%M:%S', current_timestamp())) as dbt_updated_at,
from {{ ref('stg__taxi_trips') }}
where 1=1
and (trip_end_timestamp is not null or coalesce(trip_total, 0.0) > 0)
{% if is_incremental() %}
and trip_start_date >= date(cast('{{ max_timestamp }}' as timestamp))
{% endif %}