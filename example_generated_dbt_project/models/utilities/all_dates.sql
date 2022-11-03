{{ dbt_utils.date_spine(
    datepart="day",
    start_date="CAST('2019-01-01' AS date)",
    end_date="CAST('2020-01-01' AS date)"
   )
}}
