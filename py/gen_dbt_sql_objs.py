#!/usr/bin/env python3
"""
Python Version  : 3.8
* Name          : gen_dbt_sql_objs.py
* Description   : Workflow generation script.
                : Used to generate dbt snapshot/incremental files in batch
                : Uses Jinja templates with input tables to generate required SQL files
* Created       : 23-06-2022
* Usage         : python3 gen_dbt_sql_objs.py <jinja template>
"""

__author__ = "Paul Fry"
__version__ = "0.1"

import os
import sys
import pandas as pd
from common import logger, jinja_env, verify_dir_exists
import inputs
import error_op


def generate_sql_op(data_src, src_table, rendered_sql):
    """generate an output sql file using the rendered_sql value"""
    # make the target dir if it doesn't exist
    target_dir = f"op/{data_src}/{ip_jinja_template}"
    verify_dir_exists(target_dir)

    if ip_jinja_template == 'snapshot':
        op_filepath = os.path.join(target_dir, f"{src_table}_snapshot.sql")
    else:
        op_filepath = os.path.join(target_dir, f"{src_table}.sql")

    logger.debug(f"op_filepath = {op_filepath}")

    with open((op_filepath), "w") as op_sql_file:
        op_sql_file.write(rendered_sql)

    return


def parse_data_src_summary_metadata(data_src, src_table):
    """Parse the input data dictionary"""
    table_level_metadata, metadata_sheet_name = inputs.get_ips_for_table_level_metadata()

    # read in data dictionary as df to determine 'unique_key' & 'load_date_field' fields
    df = pd.read_excel(table_level_metadata, sheet_name=metadata_sheet_name, skiprows=2).fillna("").reset_index()
    logger.debug(df)

    # filter data frame to only return the metadata for the table we're interested in
    df = df.loc[(df["data_src"] == data_src) & (df["table"] == src_table)]

    # fetch the unique_key & updated_at_field values for this table
    primary_key_field = df["primary_key"].values[0]
    created_at_field = df["created_at_field"].values[0]
    updated_at_field = df["updated_at_field"].values[0]

    logger.debug(f"primary_key = {primary_key_field}\nupdated_at_field = {updated_at_field}")

    return primary_key_field, created_at_field, updated_at_field


def render_jinja(data_src, src_table, env, snowflake_db, snowflake_db_schema_incremental, on_schema_change_behaviour):
    """Iterate through the input tables for a data_src and render/generate SQL op files"""

    # read in the CSV file to determine the 'unique_key' & 'load_date_field' fields
    primary_key_field, created_at_field, updated_at_field = parse_data_src_summary_metadata(data_src, src_table)

    # render the jinja template output
    # fmt: off
    rendered_sql = jinja_env.get_template(f"{ip_jinja_template}.sql.j2").render(
        src_tbl_name=src_table,
        source_name=data_src,
        env=env,
        primary_key=primary_key_field,
        created_at=created_at_field,
        updated_at=updated_at_field,
        snowflake_src_db=snowflake_db,
        db_schema_incremental=snowflake_db_schema_incremental,
        on_schema_change=on_schema_change_behaviour
    )
    # fmt: on

    return rendered_sql


def main():
    """Main orchestration routine"""

    # fetch list of data_src tables
    env, ip_data_src, data_src_ip_tbls, snowflake_db, snowflake_db_schema_incremental, on_schema_change_behaviour = inputs.get_ips_for_gen_sql_objs()

    # iterate through data_src_ip_tbls
    for data_src, src_tables in data_src_ip_tbls.items():
        logger.debug("--------------------------------")
        logger.debug(f"# data_src = {data_src}")
        logger.debug("--------------------------------")

        # only fetch the tables for the data_src we're interested in
        if data_src == ip_data_src:
            for src_table in src_tables:
                logger.debug("\n################################")
                logger.debug(f"# src_table = {src_table}")
                logger.debug("################################")

                # render the SQL templates for each src_table
                rendered_sql = render_jinja(data_src, src_table, env, snowflake_db, snowflake_db_schema_incremental, on_schema_change_behaviour)

                # generate a dedicated SQL file for each src_table
                generate_sql_op(data_src, src_table, rendered_sql)

    return


if __name__ == "__main__":

    # validate user input
    if len(sys.argv) < 2:
        # throw an error saying no inputs have been provided and exit.
        error_op.print_no_user_input_msg()
    else:
        ip_jinja_template = sys.argv[1]
        logger.debug(f"ip_jinja_template = {ip_jinja_template}")
        valid_cmd_line_inputs = {"snapshot": 1, "incremental": 2}

        try:
            # validate the user's cmd line input
            validate_cmd_line_ip = valid_cmd_line_inputs[ip_jinja_template]
        except KeyError:
            # throw an error saying an incorrect input arg is provided and exit.
            error_op.print_invalid_user_input_msg(ip_jinja_template)

        # call the main orchestration routine function
        main()
