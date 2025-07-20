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
    {% set max_timestamp = get_max_timestamp(last_updated_at='trip_start_date') %}
{% endif %}

select
  to_hex(sha256(concat(
    ft2.taxi_id, '|', 
    ft2.payment_type, '|', 
    ft2.company, '|', 
    format_date('%Y%m%d', ft2.trip_start_date), '|', 
    format_date('%Y%m%d', ft2.trip_end_date), '|',
    cast(dates.is_holiday as string), '|',
    ft2.trip_distance_category, '|',
    ft2.trip_traffic_category
  ))) as trips_sk,
  ft2.trip_start_date,
  ft2.trip_end_date,
  ft2.taxi_id,
  ft2.payment_type,
  ft2.company,
  dates.is_holiday,
  ft2.trip_distance_category,
  ft2.trip_traffic_category,
  count(unique_key) as total_rides,
  sum(trip_seconds) as trip_seconds,
  sum(trip_miles) as trip_miles,
  sum(fare) as fare,
  sum(tolls) as tolls,
  sum(tips) as tips,
  sum(extras) as extras,
  sum(trip_total) as trip_total
from {{ ref('fact_taxi_trips') }} ft2
left join {{ ref('dates') }} dates
on dates.date = ft2.trip_start_date
where 1=1
{% if is_incremental() %}
and trip_start_date >= date(cast('{{ max_timestamp }}' as timestamp))
{% endif %}
group by all
