# Prerequisites

Described below are the input config parameters read in from `ip/config.yaml` by the dbt code generation workflow scripts.

## General Parameters

| Parameter | Description | Example                  |
| --------- | ---------------------------- | ------- |
| env | Name of the environment | `dev` |
| abs_path_to_airflow2_dags | The absolute filepath to the Airflow dags repo on your filesystem | `/home/<user>/<git_repos_link>/airflow-v2-dags` |

## DB Connection Parameters

| Parameter | Description                  | Example |
| --------- | ---------------------------- | ------- |
| snowflake_username | Snowflake username.<br/>Update this to reflect your own Snowflake username. | `jbloggs@email.com` |
| abs_path_to_snowflake_private_key | The absolute filepath to your Snowflake .p8 key | `[abs-path-to]/rsa-key.p8` |
| snowflake_account | The Snowflake account name. | `<company_abc>.ap-southeast-2` |
| snowflake_warehouse | Snowflake warehouse to use. | `wh_svc_dbt_xs_${ENV}` |
| snowflake_role | Snowflake role to use. | `svc_dbt_${ENV}` |
| snowflake_src_db | Snowflake DB for the data_src. | `${DATA_SRC}_${ENV}` |
| snowflake_src_db_schema | Snowflake DB schema for the data_src | `landed` |

## dbt Parameters

| Parameter | Description                  | Example |
| --------- | ---------------------------- | ------- |
| dbt_version | The dbt version you want to use. I recommend using (at least) v1.2, as the `dbt-project-evaluator` package requires upwards of v1.2. | `1.2.0` |
| dbt_profile_name | * The name of the dbt profile to use, containing the credentials required to connect to your data warehouse.<br/>* Will be used to populate `profiles.yml`.<br/>* As per dbt's documentation, it's recommended to use your org name as snake_case as your profile name | `eg_company` |
| dbt_project_name | The name for your DBT project. name of the dbt project.<br/>Must be `snake_case`. I.e., letters, digits and underscores only, and cannot start with a digit. | `dbt_${DATA_SRC}` |
| dbt_model | * Typically aligns to the name of your target database.<br/>* Models are defined as `.sql` files, typically in the `models` directory)<br/>* Note: this must be lowercase and hyphens, spaces or underscores aren't allowed for this value | `staging` |

## Input Metadata File Parameters

| Parameter | Description                  | Example |
| --------- | ---------------------------- | ------- |
| table_level_metadata | * Input XLS file containing table-level metadata<br/>* This is used to capture the 'primary_key' & 'last_updated' for each src table across the data sources. | `ip/table_level_metadata.xlsx`
| metadata_sheet_name | XLS sheet name to use | `Sheet1` |

## Data Source Parameters

| Parameter | Child Parameter | Description | Example |
| --------- | --------------- | ----------- | ------- |
| data_src | Name of the data source | `data_src_a` |
| data_src_tables | List of the (data source) input tables (used for the two .py generation scripts) | `data_src_a_src_tables:`<br/>`- table_a`<br/>`- table_b` |
