
-- Use the `ref` function to select from other models

select *
from {{ ref('my_first_dbt_model') }}
where 1=1
and id = 1
-- dummy push
