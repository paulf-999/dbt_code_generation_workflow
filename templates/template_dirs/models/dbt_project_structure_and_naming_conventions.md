# dbt Model Structure and Naming Conventions

The following content has been lifting from this dbt docs reference page: [How we structure our dbt projects](https://docs.getdbt.com/guides/best-practices/how-we-structure/5-the-rest-of-the-project).

The dbt project structure below is what is recommended by dbt (see above link). The notes that follow the image below describe how/where to use (yaml) resource property files in your project.

```bash
models
├── intermediate
│   └── finance
│       ├── _int_finance__models.yml
│       └── int_payments_pivoted_to_orders.sql
├── marts
│   ├── finance
│   │   ├── _finance__models.yml
│   │   ├── orders.sql
│   │   └── payments.sql
│   └── marketing
│       ├── _marketing__models.yml
│       └── customers.sql
├── staging
│   ├── jaffle_shop
│   │   ├── _jaffle_shop__docs.md
│   │   ├── _jaffle_shop__models.yml
│   │   ├── _jaffle_shop__sources.yml
│   │   ├── base
│   │   │   ├── base_jaffle_shop__customers.sql
│   │   │   └── base_jaffle_shop__deleted_customers.sql
│   │   ├── stg_jaffle_shop__customers.sql
│   │   └── stg_jaffle_shop__orders.sql
│   └── stripe
│       ├── _stripe__models.yml
│       ├── _stripe__sources.yml
│       └── stg_stripe__payments.sql
└── utilities
    └── all_dates.sql
```

## Create (yaml) Resource Property Files per Folder

* As in the example above, create a `_[dbt_project]__models.yml` per directory in your `models` folder that configures all the models in that directory.
  * For `staging` folders, also include a `_[dbt_project]__sources.yml` per directory.
* The leading underscore ensure your `YAML` files will be sorted to the top of every folder to make them easy to separate from your models.
* If you use `doc blocks` in your project, we recommend following the same pattern, and creating a `_[dbt_project]__docs.md` markdown file per directory containing all your `doc blocks` for that folder of models.

## Cascade configs using `dbt_project.yml`

* Leverage your `dbt_project.yml` to set default configurations at the directory level.
* Use the well-organized folder structure we’ve created thus far to define the baseline schemas and materializations, and use dbt’s cascading scope priority to define variations to this.
* For example, (as below):
  * Define your `marts` to be **materialized as tables** by default
  * Define separate schemas for our separate subfolders
  * Any models that need to use incremental materialization can be defined at the model level.
