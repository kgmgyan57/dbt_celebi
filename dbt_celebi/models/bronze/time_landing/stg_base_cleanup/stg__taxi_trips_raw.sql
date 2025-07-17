{{ config(
    dataset = "landing_dbt_transform",
    materialized = "view",
    unique_key=['unique_key'],
    tags = ["taxi_trips"],
    author = "@gyan"
) }}

select * 
from {{ source("chicago_taxi_trips", "taxi_trips_raw") }}