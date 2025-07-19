{{ config(
    dataset = "looker_core",
    materialized = "view",
    author = "@gyan"
  ) 
}}

select
*
from {{ ref('dim_dates')}}