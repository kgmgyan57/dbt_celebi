{{
    config(
        schema = "looker_core",
        materialized = "table",
        unique_key=['taxi_id'],
        author = "@gyan",
        tags = ["core", "taxi_trips"],
        on_schema_change = "append_new_columns",
    )
}}


with trip_intervals as (
    select
      taxi_id,
      trip_start_timestamp,
      trip_end_timestamp,
      lag(trip_end_timestamp) over (partition by taxi_id order by trip_start_timestamp) as prev_trip_end
    from {{ ref('fact_taxi_trips') }}
    where trip_seconds is not null
)

overwork_sessions as (
  select *
  from taxi_shifts_base
  where timestamp_diff(trip_start_timestamp, prev_trip_end, hour) < 8
)

select
  taxi_id,
  count(*) as long_shift_sessions
from overwork_sessions
group by taxi_id