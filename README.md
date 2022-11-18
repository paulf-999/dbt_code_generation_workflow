# dbt Code Generation Workflow

Automation scripts to accelerate dbt development, namely using code generation scripts to:

1. Automate the dbt project setup process, designing the project to follow [dbt's recommended project structure](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview).
2. Automate the creation of the dbt `_sources.yml` resource property file for a given data source.
3. Generate (dbt) SQL files in bulk either as: `snapshots` tables or `incremental` loads.
4. Use dbt `pre-commit` packages to ensure dbt standards and naming conventions are upheld (see `dbt-gloss` in `.pre-commit-config.yaml`).

Doing this ensures that new dbt projects implement best practices from the off and removes much of the manual heavy lifting of dbt projects. See [example_generated_dbt_project](https://github.com/paulf-999/dbt_code_generation_workflow/tree/feature/dbt_gloss/example_generated_dbt_project) as an example dbt project generated using these scripts.

Note, re: steps 2 and 3 - there's also a routine to add new data sources to an existing dbt project. For more details, see the section below 'How to Add a New Data Source'.

---

## Contents

1. Goal
2. How to Run
3. How to Add a New Data Source
4. Implementation Details

---

## 1. Goal

The goal of these scripts is to accelerate dbt development through the use of code generation scripts. These scripts look to:

**Automate the dbt Project Setup Process**

As well as automating the dbt project setup, the project is designed to follow [dbt's recommended project structure](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview) and implement best practices. Expand the menu below for more details.

<details>

<summary>Expand for more details</summary>

* See `initialise_dbt_project` in the Makefile.
* The target `initialise_dbt_project` automates the dbt project setup process by:

   * Populating the `dbt_project.yml` and `profiles.yml` files & verifying the connectivity.
   * Providing a template `packages.yml` to bundle the install of best-practice dbt packages, e.g.:
     * `dbt_utils`
     * `dbt_expectations`
     * `dbt-codegen`
     * `dbt-project-evaluator`
   * Include additional (generic) dbt source tests, e.g.:
     * `raw_table_existence`
     * `is_table_empty`
   * Include additional dbt macros, e.g.:
     * `limit_row_count` - custom macro to limit row counts when in lower (e.g., dev) environments
     * `generate_schema_name` - commonly revised dbt macro
     * `grant_select_on_schemas` - dbt-recommended macro to grant access to all tables in a schema
     * And recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview), as shown below:

<details>

<summary>Click to show target dbt project structure</summary>

```bash
${DBT_PROJECT_NAME}
├── analysis
├── data
├── docs
│   └── pull_request_template.md
├── macros
│   ├── _macros.yml
│   ├── generate_schema_name.sql
│   └── grant_select_on_schemas.sql
├── models
│   ├── intermediate
│   │   ├── _int_<entity>__<verb>.yml.j2 # just a placeholder
│   │   └── example_cte.sql.j2 # placeholder
│   ├── marts
│   │   ├── _models.yml.j2 # placeholder
│   │   └── dim_customer.sql.j2 # placeholder
│   ├── staging
│   │   ├── ${DBT_PROJECT_NAME}
│   │   │   ├── ${DBT_PROJECT_NAME}__docs.md
│   │   │   ├── ${DBT_PROJECT_NAME}__models.yml
│   │   │   ├── ${DBT_PROJECT_NAME}__sources.yml
│   │   │   ├── base (TBC)
│   │   │   │   ├── base_${DBT_PROJECT_NAME}__customers.sql
│   │   │   │   └── base_${DBT_PROJECT_NAME}__deleted_customers.sql
│   │   │   ├── ${DBT_PROJECT_NAME}__customer.sql
│   └── utilities
│       └── all_dates.sql
├── snapshots
│   └── ${DATA_SRC}
│       └── ${DATA_SRC_SRC_TABLE}_snapshot.sql
├── tests
│   └── generic
│       └── sources
│            ├── existence
│            |   └── raw_table_existence.sql
│            └── row_count
│                └── is_table_empty.sql
├── README.md
├── dbt_project.yml
└── packages.yml
```

</details>

</details>

**Automate the creation of the dbt `_sources.yml` resource property file for a given data source**

<details>

<summary>Expand for more details</summary>

* See `gen_source_properties_file` in the `Makefile`.
* This step automates the creation of the dbt source properties file (i.e., `_sources.yml`) for each data source, using the python script `py/gen_dbt_src_properties.py`.
* A key prerequisite for this step is for the user to supply data dictionary type input file, to indicate (per table) at a field-level:
  * The field description
  * and flags to indicate whether the following 'generic' dbt test should be applied to the field:
    * Unique
    * Not null
    * Accepted values
    * Relationship constraints

</details>

**Generate (dbt) sql files in bulk that use the [`snapshot`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/templates/jinja_templates/snapshot.sql.j2) and [`incremental`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/templates/jinja_templates/incremental.sql.j2) patterns**

<details>

<summary>Expand for more details</summary>

* See `gen_dbt_sql_objs` in the `Makefile`.
* This steps automates the creation of (dbt) SQL files in bulk (either as: `snapshot` or `incremental [load]` SQL files) using Jinja templates. It does this using the python script `py/gen_dbt_sql_objs.py`.
* As with step 2 'Generate the dbt 'source properties' file', a key prerequisite for this step is for the user to supply a data-dictionary type input file (this time at the data source-level), to indicate per source table what the:
  * Primary key is
  * and what the 'last_updated_field' is per table

</details>

---

## 2. How to Run

Before you do anything, ensure you install and setup `pre-commit` by running:

```bash
pip install -r requirements.txt
pre-commit install
```

### Prerequisites

* Ensure you provide values for each of the keys in [`ip/config.yaml`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/ip/config.yaml).
  * For a description breakdown of each of the input args, see [`ip/README.md`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/ip/README.md).
* Review the input args used for the data dictionary field mapping args,
  * If you used the template data dictionary file, no changes will be required.
  * For more details, see [`ip/data_dic_field_mapping_prereqs.md`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/ip/data_dic_field_mapping_prereqs.md).

### Steps

1. Update the input parameters within [`ip/config.yaml`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/ip/config.yaml).

2. Upload an input data dictionary to the `ip/` folder and (if required) review the value of the `data dictionary` key within [`ip/data_dic_field_mapping_config.yaml`](https://github.com/paulf-999/dbt_code_generation_workflow/blob/main/ip/data_dic_field_mapping_config.yaml).
3. Install the prerequisites libraries by running: `make deps`.
4. Run `make install` to:

<details>

<summary>Expand for more details</summary>

* Set up a dbt project, designing the project th follow [dbt's recommended project structure](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview) and validate source DB connectivity.
* Generate a dbt resource properties file (`_sources.yml`) using data from an input data dictionaries/metadata.
* Recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview).
* Generate (dbt) SQL files in bulk either as: snapshots tables or incremental loads.

</details>

---

## 3. How to Add a New Data Source

If you've previously ran `make install` to generate the template dbt project, you can then do the following to add a new data source to your dbt project (click menu to expand):

<details>

<summary>Expand for more details</summary>

1. Update the `data_src` parameter within [`ip/config.yaml`](https://gitlab.com/wesfarmers-aac-engineers/data-engineering/wes-aac-dbt-accelerators/-/blob/main/ip/config.yaml) (underneath `general_params`) to reflect the data source you want to add.
2. Upload an input data dictionary to the `ip` folder and ensure it matches the value of the `data dictionary` key within [`ip/data_dic_field_mapping_config.yaml`](https://gitlab.com/wesfarmers-aac-engineers/data-engineering/wes-aac-dbt-accelerators/-/blob/main/ip/data_dic_field_mapping_config.yaml) accordingly.
3. Run `make add_data_source` to:

* Generate a dbt resource properties file (`_sources.yml`) using data from an input data dictionaries/metadata.
* Generate (dbt) SQL files in bulk either as: snapshots tables or incremental loads.
* and import both of these into the previously generated dbt project.

</details>

---

## 4. Implementation Details

See [docs/implementation_details.md](docs/implementation_details.md).
