{%- macro get_max_timestamp(last_update_column) %}

    {% set max_ts_query %}

        select COALESCE(MAX(CAST({{ last_update_column }} AS DATETIME)), CAST('2000-01-01' AS DATETIME)) as ts_max

        from {{ this }}
    {% endset %}

    {% set results = run_query(max_ts_query) %}
    {% if execute %}
        {{ return (results.columns[0].values()[0]) }}
    {% else %}
        {{ return ('2000-01-01') }}
    {% endif %}

{%- endmacro -%}