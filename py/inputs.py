import logging
import os

import yaml

# Set up a specific logger with our desired output level
logging.basicConfig(format="%(message)s")
logger = logging.getLogger("application_logger")
logger.setLevel(logging.INFO)

working_dir = os.getcwd()


def read_ip_config_file():
    """Read input from config file"""
    with open(os.path.join(working_dir, "ip", "config.yaml")) as ip_yml:
        data = yaml.safe_load(ip_yml)

    return data


def read_ip_field_mapping_data():
    """Read input from field mapping config file"""
    with open(os.path.join(working_dir, "ip", "data_dic_field_mapping_config.yaml")) as ip_yml:
        field_mapping_data = yaml.safe_load(ip_yml)

    return field_mapping_data


######################################################################################################
# Get inputs functions for gen_dbt_model_directory.py
######################################################################################################
def get_ips_for_gen_dbt_model_directory():
    """Read input from config file for gen_dbt_model_directory.py"""

    data = read_ip_config_file()
    data_src = data["data_src_params"]["data_src"]
    dbt_project_name = data["dbt_params"]["dbt_project_name"]

    return data_src, dbt_project_name


######################################################################################################
# Get inputs functions for gen_dbt_sql_objs.py
######################################################################################################
def get_ips_for_gen_sql_objs():
    """Read input from config file for gen_dbt_sql_objs.py"""

    data = read_ip_config_file()
    env = data["general_params"]["env"]
    data_src = data["data_src_params"]["data_src"]
    on_schema_change_behaviour = data["data_src_params"]["on_schema_change_behaviour"]

    # data_src table specific key/values
    data_src_ip_tbls = {}
    # TODO - the input for this would need to be manually changed
    data_src_ip_tbls["data_src_a"] = data["general_params"]["data_src_tables"]["data_src_a_src_tables"]
    snowflake_db = data["db_connection_params"]["snowflake_src_db"].replace("${DATA_SRC}", data_src).replace("${ENV}", env)
    snowflake_db_schema_incremental = data["db_connection_params"]["snowflake_db_schema_incremental"]

    return env, data_src, data_src_ip_tbls, snowflake_db, snowflake_db_schema_incremental, on_schema_change_behaviour


def get_ips_for_table_level_metadata():
    data = read_ip_config_file()

    table_level_metadata = data["ip_metadata_file_params"]["table_level_metadata"]
    metadata_sheet_name = data["ip_metadata_file_params"]["metadata_sheet_name"]

    return table_level_metadata, metadata_sheet_name


######################################################################################################
# Get inputs functions for for gen_source_properties.py
######################################################################################################
def get_ips_for_src_properties():
    """Read input from config file for gen_source_properties.py"""
    data = read_ip_config_file()

    field_mapping_data = read_ip_field_mapping_data()

    env = data["general_params"]["env"]
    data_src = data["data_src_params"]["data_src"]
    src_snowflake_db = data["db_connection_params"]["snowflake_src_db"].replace("${DATA_SRC}", data_src).replace("${ENV}", env)
    src_db_schema = data["db_connection_params"]["snowflake_src_db_schema"]

    # data dictionary inputs
    data_dictionary = field_mapping_data["data_dictionary"].replace("{data_src}", data_src)
    target_op_src_filename = field_mapping_data["target_op_src_filename"].replace("{data_src}", data_src)
    data_src_tables = data["data_src_params"]["data_src_tables"]

    # the loop below just helps ensure the script is generic, regardless of the data_src
    xls_sheet_names = []

    for src, ip_tbls in data_src_tables.items():
        # only fetch the tables for the targeted data_src
        if src.startswith(data_src) is True:
            for tbl in ip_tbls:
                xls_sheet_names.append(tbl)

    return env, data_src, src_snowflake_db, src_db_schema, data_dictionary, xls_sheet_names, target_op_src_filename


def get_data_dictionary_args():
    """Get inputs specifying what mapping fields to use for the data dictionary"""
    field_mapping_data = read_ip_field_mapping_data()

    col_name_field = field_mapping_data["field_name_mappings"]["data_dic_col_name_field"]
    description_field = field_mapping_data["field_name_mappings"]["data_dic_descrip_field"]
    primary_key_field = field_mapping_data["field_name_mappings"]["data_dic_primary_key_field"]
    created_at_field = field_mapping_data["field_name_mappings"]["data_dic_created_at_field"]
    updated_at_field = field_mapping_data["field_name_mappings"]["data_dic_updated_at_field"]
    unique_field = field_mapping_data["field_name_mappings"]["data_dic_unique_field"]
    not_null_field = field_mapping_data["field_name_mappings"]["data_dic_not_null_field"]
    accepted_values_field = field_mapping_data["field_name_mappings"]["data_dic_accepted_values_field"]
    fk_constraint_table_field = field_mapping_data["field_name_mappings"]["data_dic_fk_constraint_table_field"]
    fk_constraint_key_field = field_mapping_data["field_name_mappings"]["data_dic_fk_constraint_key_field"]

    return col_name_field, description_field, primary_key_field, created_at_field, updated_at_field, unique_field, not_null_field, accepted_values_field, fk_constraint_table_field, fk_constraint_key_field  # noqa
