# Templates

'Template' files/folders are used in two ways in these scripts, according to which directory they come from:

| Directory       | Description                  |
| ----------------| ---------------------------- |
| jinja_templates | Contains Jinja templates (i.e., files ending in `.j2`) that are rendered to generate files required by the dbt project. |
| template_dirs   | Contains files/folders that follow best practice patterns and are copied over to the target dbt project. |

## `jinja_templates` Directory

Described below are the 5 jinja template files used:

| Jinja Template     | Description         | Input Args Required | Used by |
| ------------------ | ------------------- | ------------------- | ------- |
| `dbt_project.yml.j2` | * Used to generate the `dbt_project.yml` file | * ${DBT_PROJECT_NAME}<br/>* ${DBT_PROFILE_NAME}<br/>* ${DBT_VERSION}. | `Makefile`, specifically the target `initialise_dbt_project` |
| `incremental.sql.j2` | * Used to generate the SQL required to perform the dbt 'incremental' pattern (i.e. type-2 incremental load) for each data source table | * ${on_schema_change}<br/>* ${src_tbl_name}<br/>* ${updated_at} | `py/gen_dbt_sql_objs.py` |
| `snapshot.sql.j2` | * Used to generate the SQL required for the dbt 'snapshot' command for each data source table | * ${src_tbl_name}<br/>* ${snowflake_src_db}<br/>* ${primary_key}<br/>* ${updated_at}<br/>* ${source_name} | `py/gen_dbt_sql_objs.py` |
| `src_properties_generator` | * The jinja templates in this directory are used to generate the dbt `_source.yml` resource properties file | * ${DATA_SRC}<br/>* ${src_db}<br/>* ${src_db_schema}<br/>* ${src_tbl_name}| `py/gen_dbt_src_properties.py` |
| `source.yml.j2` | * This jinja template forms part of the templates used to generate the dbt `_source.yml` resource properties file<br/>* However, it's worth calling this template out as contains significantly more logic than all other templates<br/>* The reason for this is because it conditionally adds (generic) dbt tests based upon the input values provided in the input data dictionary. | * ${col_name}<br/>* ${col_description}<br/>* ${accepted_values}<br/>* ${fk_constraint_table}<br/>* ${fk_constraint_key} | `py/gen_dbt_src_properties.py` |
| `README.md.j2` | * Used to generate the README.md file for the dbt project repo | * ${DBT_PROJECT_NAME}<br/>* ${DATA_SRC} | `Makefile`, specifically the target `initialise_dbt_project` |

## `template_dirs` Directory

This directory largely contains (best practice) files and folders that are to be copied as-is to the target dbt project.

### `template_dirs/models` Directory

The only exception to this is the `models` directory. In order to recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview), the python script `py/gen_dbt_model_directory.py` is used to rename files and folders using values provided in the input `config.yaml` file, namely things like ${DBT_PROJECT NAME}.

## Example Jinja Template Output

For examples of rendered Jinja template output, see [example_template_ops](https://github.com/paulf-999/dbt/tree/main/dbt_code_generation_workflow/templates/example_template_ops). The reason for showing these is because the templates are at times difficult to read, as a result of having to escape dbt's usage of curly braces.
