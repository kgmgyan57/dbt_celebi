{{
    config(
        schema = "dimensions",
        materialized = "table",
        unique_key=['date'],
        author = "@gyan",
        tags = ["dim_trips", "taxi_trips"],
        on_schema_change = "append_new_columns",
    )
}}

-- Date dimension with holidays using macro
WITH raw_dates AS (
  SELECT *
  FROM UNNEST(GENERATE_DATE_ARRAY(DATE '2013-01-01', DATE '2025-12-31', INTERVAL 1 DAY)) date
)
SELECT
  date,
  DATE_TRUNC(date, WEEK(MONDAY)) AS week_start_date,
  DATE_TRUNC(date, WEEK(MONDAY)) + 6 AS week_end_date,
  EXTRACT(DAYOFWEEK FROM date) AS day_of_week,
  EXTRACT(MONTH FROM date) AS month_seq_number,
  FORMAT_DATE('%B', date) AS month_name,
  DATE(DATE_TRUNC(date, MONTH)) AS month_start_date,
  DATE(LAST_DAY(date)) AS month_end_date,
  EXTRACT(YEAR FROM date) AS year,
  {{ is_holiday('date') }} AS is_holiday
FROM raw_dates