{%- macro get_max_timestamp(last_updated_at) %}

    {% set max_ts_query %}

        select COALESCE(MAX(CAST({{ last_updated_at }} AS DATETIME)), CAST('2010-01-01' AS DATETIME)) as ts_max

        from {{ this }}
    {% endset %}

    {% set results = run_query(max_ts_query) %}
    {% if execute %}
        {{ return (results.columns[0].values()[0]) }}
    {% else %}
        {{ return ('2010-01-01') }}
    {% endif %}

{%- endmacro -%}