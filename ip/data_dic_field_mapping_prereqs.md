# Data Dictionary Field Mapping Parameters

Described below are the parameters used for retrieving field-level metadata from an input data dictionary. This metadata is then used to capture field-level DQ tests & descriptions for dbt.

## General Parameters

| Parameter | Description | Example                  |
| --------- | ---------------------------- | ------- |
| data_dictionary | Name of the input data dictionary file to be used to retrive data source metadata. | `ip/{data_src}_data_dictionary.xlsx` |
| target_op_src_filename | Name of the target dbt source properties file. | `_{data_src}_source.yml` |

## Field Name Mapping Parameters

| Parameter | Description                  | Example |
| --------- | ---------------------------- | ------- |
| data_dic_col_name_field | Data dictionary column used to capture the field name. | `field` |
| data_dic_descrip_field | Data dictionary column used to capture the field description. | `description` |
| data_dic_primary_key_field | Data dictionary column used to indicate whether a field represents the primary key. | `primary_key` |
| data_dic_created_at_field | Data dictionary column used to indicate when the record was created. | `created_at_field` |
| data_dic_updated_at_field | Data dictionary column used to indicate when the record was updated. | `updated_at_field` |
| data_dic_unique_field | Data dictionary column used to indicate the whether the value should be unique. | `unique` |
| data_dic_not_null_field | Data dictionary column used to indicate not_null. | `not_null` |
| data_dic_accepted_values_field | Data dictionary column used to indicate 'accepted values'. | `accepted_values` |
| data_dic_fk_constraint_table_field | Data dictionary column used to indicate the foreign key relationship table. | `fk_constraint_table` |
| data_dic_fk_constraint_key_field | Data dictionary column used to indicate the foreign key ID field. | `fk_constraint_key` |
