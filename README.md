# dbt Code Generation Workflow

Automation scripts to accelerate dbt development, namely using code generation scripts to:

1. Automate the dbt project setup process, designing the project to follow best practices & include common best practice files.
2. Generate (dbt) SQL files in bulk either as: `snapshots` tables or `incremental` loads.
3. Automate the creation of the dbt `_source.yml` resource property file for a given data source.
4. Recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview).

Note, re: step 3 - there's also a routine to add new data sources, see 'How to Add a New Data Source if the dbt Project Already Exists'.

---

## Contents

1. Goal
2. How to Run

* Prerequisites
* Steps
* How to Add a New Data Source if the dbt Project Already Exists

3. Implementation Details

---

### 1. Goal

The goal of these scripts is to accelerate dbt development through the use of code generation scripts. These automation scripts look to:

#### 1. Automate the dbt Project Setup Process

It does this by:

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

#### 2. Generate (dbt) sql files in bulk that use the [`snapshot`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/templates/jinja_templates/snapshot.sql.j2) and [`incremental`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/templates/jinja_templates/incremental.sql.j2) patterns (templates)

#### 3. Automate the creation of the dbt `_source.yml` resource property file for a given data source

* And importantly include (dbt) `unique` and `not null` tests for every source primary key.
* Add additional generic dbt tests (e.g., unique, not_null, accepted_values, relationships) per column, as indicated by the (template) input data dictionary.

#### 4. Recreate the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview)

As shown below:

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
│   │   │   │   ├── base_jaffle_shop__customers.sql
│   │   │   │   └── base_jaffle_shop__deleted_customers.sql
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

## 2. How to Run

### Prerequisites

Before you run the above commands, ensure you provide values for each of the keys in [`ip/config.yaml`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/config.yaml). For a description breakdown of each of the input args, see [`ip/README.md`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/README.md).

In addition, for a breakdown of each of the input args used for the data dictionary field mapping args, see [`ip/data_dic_field_mapping_prereqs.md`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/data_dic_field_mapping_prereqs.md).

### Steps

1. Update the input parameters within [`ip/config.yaml`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/config.yaml).
2. Update the other input parameters within [`ip/data_dic_field_mapping_config.yaml`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/data_dic_field_mapping_config.yaml).
3. Upload an input data dictionary to the `ip` folder and update the value of the `data dictionary` key within [`ip/data_dic_field_mapping_config.yaml`](https://github.com/paulf-999/dbt/blob/main/dbt_code_generation_workflow/ip/data_dic_field_mapping_config.yaml) accordingly.
4. Install the prerequisites libraries by running: `make deps`.
5. Run `make install` to:

* Set up a dbt project and validate source DB connectivity.
* Generate a dbt resource properties file (`_source.yml`) using data from an input data dictionaries/metadata.
* Recreates the [target dbt project structure recommended by dbt](https://docs.getdbt.com/guides/best-practices/how-we-structure/1-guide-overview#guide-structure-overview).
* Generate (dbt) SQL files in bulk either as: snapshots tables or incremental loads.

---

### How to Add a New Data Source if the dbt Project Already Exists

Note: a prerequisite to this step is for you to have previously run `make install` - i.e., for you to have already generated the template dbt project.

Assuming you have done this, do the following to add a new data source to your dbt project:

1. Update the `data_src` parameter within [`ip/config.yaml`](https://gitlab.com/wesfarmers-aac-engineers/data-engineering/wes-aac-dbt-accelerators/-/blob/main/ip/config.yaml) (underneath `general_params`) to reflect the data source you want to add.
2. Upload an input data dictionary to the `ip` folder and ensure it matches the value of the `data dictionary` key within [`ip/data_dic_field_mapping_config.yaml`](https://gitlab.com/wesfarmers-aac-engineers/data-engineering/wes-aac-dbt-accelerators/-/blob/main/ip/data_dic_field_mapping_config.yaml) accordingly.
3. Run `make add_data_source` to:

* Generate a dbt resource properties file (`_source.yml`) using data from an input data dictionaries/metadata.
* Generate (dbt) SQL files in bulk either as: snapshots tables or incremental loads.
* and import both of these into the previously generated dbt project.

---

## 3. Implementation Details

See [implementation_details.md](implementation_details.md).
