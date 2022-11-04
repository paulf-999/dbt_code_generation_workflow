# Implementation Details

A `Makefile` has been used to orchestrate the steps required to set up a dbt project. Whereby this dbt project also bundles in commonly used dbt packages, macros and templates to ensure best practice naming/structures are followed . The orchestration steps consist of:

## 1. Automate the dbt Project Setup

* See `initialise_dbt_project` in the `Makefile`.
* This step automates the creation of a dbt project using inputs provided in `ip/config.yaml` to populate Jinja templates (see `templates` dir), as well as:

  * Populate the `profiles.yml` and verifying source DB connectivity, using the creds you provide (from `ip/config.yaml`)
  * Bundle in the install of best-practice dbt packages, e.g.: `dbt_util`, `dbt-codegen` and `dbt_expectations` & `dbt-project-evaluator`.
  * Include additional dbt macros, e.g.: `generate_schema_name`, as well as macros used for DQ testing.

## 2. Generate (dbt) SQL files in bulk either as: `snapshots` tables or `incremental` loads

* See `gen_dbt_sql_objs` in the `Makefile`.
* This steps automates generating (dbt) SQL files in bulk (either as: `snapshot` or `incremental [load]` SQL files) using Jinja templates. It does this using the python script `py/gen_dbt_sql_objs.py`.
* As with step 2 'Generate the dbt 'source properties' file', a key prerequisite for this step is for the user to supply a data-dictionary type input file (this time at the data source-level), to indicate per source table what the:
  * Primary key is
  * and what the 'last_updated_field' is per table

## 3. Generate the dbt 'source properties' file (`_source.yml`)

* See `gen_source_properties_file` in the `Makefile`.
* This step automates the creation of the dbt source properties file (i.e., `_source.yml`) for each data source, using the python script `py/gen_dbt_src_properties.py`.
* A key prerequisite for this step is for the user to supply data dictionary type input file, to indicate (per table) at a field-level:
  * The field description
  * and flags to indicate whether the following 'generic' dbt test should be applied to the field:
    * Unique
    * Not null
    * Accepted values
    * Relationship constraints

## 4. Recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview)

* See the python script `py/gen_dbt_model_directory.py`.
* The goal of this step is to recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview). Doing this ensures that:
  * The `models` folder contains dedicated `staging`, `intermediate` and `marts` directories at the root.
  * Dedicated `_sources.yml` & `models.yml` files are created within the `staging` folder.
  * A dedicated `models.yml` file is created within the `marts` folder.
  * And finally, example SQL files (each containing boilerplate CTE 'import, logical and final' section code) within each of these (saved as `.j2` templates to avoid compilation errors).

## Note: Data Dictionary/Metadata Required for Features 2 and 3

As mentioned, features 2 and 3 above rely on using an input data dictionary file to generate the respective output files. As such, if you don't want to make use of this, comment out the calls to the targets `gen_dbt_sql_objs` and `gen_source_properties_file` in the `Makefile`.

For more information on the fields & field mappings used for any input data dictionary, see [`ip/data_dic_field_mapping_prereqs.md`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/data_dic_field_mapping_prereqs.md).
