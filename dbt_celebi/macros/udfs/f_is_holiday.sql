-- Create a UDF to check if a date is a US federal holiday, including observance rules

{% macro is_holiday(input_date) %}
  CASE
    -- New Year's Day (January 1, observed on Dec 31 if Sat, Jan 2 if Sun)
    WHEN (EXTRACT(MONTH FROM {{ input_date }}) = 1 AND EXTRACT(DAY FROM {{ input_date }}) = 1
          AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) NOT IN (1, 7))
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 12 AND EXTRACT(DAY FROM {{ input_date }}) = 31
             AND EXTRACT(DAYOFWEEK FROM DATE_SUB({{ input_date }}, INTERVAL 1 DAY)) = 7)
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 1 AND EXTRACT(DAY FROM {{ input_date }}) = 2
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2)
         THEN 1
    -- Martin Luther King Jr. Day (3rd Monday in January)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 1 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2
         AND EXTRACT(DAY FROM {{ input_date }}) BETWEEN 15 AND 21 THEN 1
    -- Presidents' Day (3rd Monday in February)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 2 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2
         AND EXTRACT(DAY FROM {{ input_date }}) BETWEEN 15 AND 21 THEN 1
    -- Memorial Day (last Monday in May)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 5 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2
         AND EXTRACT(DAY FROM {{ input_date }}) >= 25 THEN 1
    -- Juneteenth (June 19, observed on June 18 if Sat, June 20 if Sun)
    WHEN (EXTRACT(MONTH FROM {{ input_date }}) = 6 AND EXTRACT(DAY FROM {{ input_date }}) = 19
          AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) NOT IN (1, 7))
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 6 AND EXTRACT(DAY FROM {{ input_date }}) = 18
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 6)
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 6 AND EXTRACT(DAY FROM {{ input_date }}) = 20
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2)
         THEN 1
    -- Independence Day (July 4, observed on July 3 if Sat, July 5 if Sun)
    WHEN (EXTRACT(MONTH FROM {{ input_date }}) = 7 AND EXTRACT(DAY FROM {{ input_date }}) = 4
          AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) NOT IN (1, 7))
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 7 AND EXTRACT(DAY FROM {{ input_date }}) = 3
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 6)
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 7 AND EXTRACT(DAY FROM {{ input_date }}) = 5
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2)
         THEN 1
    -- Labor Day (1st Monday in September)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 9 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2
         AND EXTRACT(DAY FROM {{ input_date }}) <= 7 THEN 1
    -- Columbus Day (2nd Monday in October)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 10 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2
         AND EXTRACT(DAY FROM {{ input_date }}) BETWEEN 8 AND 14 THEN 1
    -- Veterans Day (November 11, observed on Nov 10 if Sat, Nov 12 if Sun)
    WHEN (EXTRACT(MONTH FROM {{ input_date }}) = 11 AND EXTRACT(DAY FROM {{ input_date }}) = 11
          AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) NOT IN (1, 7))
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 11 AND EXTRACT(DAY FROM {{ input_date }}) = 10
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 6)
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 11 AND EXTRACT(DAY FROM {{ input_date }}) = 12
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2)
         THEN 1
    -- Thanksgiving (4th Thursday in November)
    WHEN EXTRACT(MONTH FROM {{ input_date }}) = 11 AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 5
         AND EXTRACT(DAY FROM {{ input_date }}) BETWEEN 22 AND 28 THEN 1
    -- Christmas Day (December 25, observed on Dec 24 if Sat, Dec 26 if Sun)
    WHEN (EXTRACT(MONTH FROM {{ input_date }}) = 12 AND EXTRACT(DAY FROM {{ input_date }}) = 25
          AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) NOT IN (1, 7))
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 12 AND EXTRACT(DAY FROM {{ input_date }}) = 24
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 6)
         OR (EXTRACT(MONTH FROM {{ input_date }}) = 12 AND EXTRACT(DAY FROM {{ input_date }}) = 26
             AND EXTRACT(DAYOFWEEK FROM {{ input_date }}) = 2)
         THEN 1
    ELSE 0
  END
{% endmacro %}