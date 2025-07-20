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
        lag(trip_end_timestamp) over (partition by taxi_id order by trip_start_timestamp) as prev_trip_end,
        timestamp_diff(trip_start_timestamp, lag(trip_end_timestamp) over (partition by taxi_id order by trip_start_timestamp), hour) as break_hours,
        timestamp_diff(trip_end_timestamp, trip_start_timestamp, hour) as shift_hours
    from {{ ref('fact_taxi_trips') }}
)
select
    taxi_id,
    count(*) as long_shift_count,
    sum(case when break_hours < 8 then 1 else 0 end) as short_break_count,
    row_number() over (order by count(*) desc, 
    sum(case when break_hours < 8 then 1 else 0 end) desc) as overworker_rank
from trip_intervals
where shift_hours >= 8
group by taxi_id
having long_shift_count > 0