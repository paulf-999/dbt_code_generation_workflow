# Python Scripts

The python scripts used in this repo are largely used in combination with Jinja templates to generate files required for every dbt project.

| Python Script                   | Description |
| ------------------------------- | ----------- |
| `py/gen_dbt_src_properties.py`  | Used to generate the dbt `_source.yml` resource properties file using Jinja templates within the directory `templates/src_properties_generator/`. |
| `py/gen_dbt_sql_objs.py`        | Used to generate dbt snapshot or incremental sql files in bulk, using the Jinja templates `templates/snapshot.sql.j2` and `templates/incremental.sql.j2`. |
| `py/gen_dbt_model_directory.py` | Used to recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview). |

For more information on the Jinja templates used by each of the Python scripts above, see: [`templates/README.md`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/templates/README.md).
