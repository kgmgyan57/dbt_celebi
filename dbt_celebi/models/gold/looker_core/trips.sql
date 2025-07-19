{{
    config(
        schema = "looker_core",
        materialized = "incremental",
        incremental_startegy='merge',
        unique_key=['trips_sk'],
        partition_by={
            "field": "trip_start_date",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by = "company",
        author = "@gyan",
        tags = ["core", "taxi_trips"],
        on_schema_change = "append_new_columns",
    )
}}

{% if is_incremental() %}
    {% set start_date = date(get_max_timestamp(last_updated_at='trip_start_date')) %}
{% endif %}

select
  to_hex(sha256(concat(taxi_id, '|', payment_type, '|', company, '|', format_date('%Y%m%d',trip_start_date)))) as trips_sk,
  trip_start_date,
  trip_end_date,
  taxi_id,
  payment_type,
  company,
  count(unique_key) as total_rides,
  sum(trip_seconds) as trip_seconds,
  sum(trip_miles) as trip_miles,
  sum(fare) as fare,
  sum(tolls) as tolls,
  sum(tips) as tips,
  sum(extras) as extras,
  sum(trip_total) as trip_total
from {{ ref('fact_taxi_trips') }}
where 1=1
{% if is_incremental() %}
and trip_start_date >= start_date
{% endif %}
group by all
