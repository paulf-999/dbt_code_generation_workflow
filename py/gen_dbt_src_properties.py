#!/usr/bin/env python3
"""
Python Version  : 3.8
* Name          : gen_source_properties.py
* Description   : Parses a data dictionary file to generate a dbt source.yml file
* Created       : 03-10-2022
* Usage         : python3 gen_dbt_src_properties.py
"""

__author__ = "Paul Fry"
__version__ = "0.1"

import os
import pandas as pd
from common import logger, jinja_env_source, verify_dir_exists
import inputs


def generate_source_properties_for_table(list_col_name_description_pairs):
    """Generate properties using input from an XLS sheet (i.e., table)"""

    # store the sum of the rendered field/comments/tests generated
    sum_rendered_table_pairs_op = ""

    for pair in list_col_name_description_pairs:
        logger.debug(pair)

        # fmt: off
        rendered_table_pairs = jinja_env_source.get_template("source.yml.j2").render(
            col_name=pair[0].strip(),
            col_description=pair[1].strip(),
            primary_key=pair[2],
            created_at=pair[3],
            updated_at=pair[4],
            unique=pair[5],
            not_null=pair[6],
            accepted_values=pair[7],
            fk_constraint_table=pair[8],
            fk_constraint_key=pair[9],
        )
        # fmt: off
        sum_rendered_table_pairs_op += f"\n{rendered_table_pairs}"

    logger.debug(sum_rendered_table_pairs_op)

    return sum_rendered_table_pairs_op


def read_xls_file(data_dictionary, xls_sheet_name):
    """Read and cleanse column name/descriptions from xls file.
    Args:   data_dictionary (string): Input xls file
            xls_sheet_name (string): Name of the xls sheet
    Returns: list_col_name_description_pairs (list): List containing column name/description pairs
    """

    col_name_field, description_field, primary_key_field, created_at_field, updated_at_field, unique_field, not_null_field, accepted_values_field, fk_constraint_table_field, fk_constraint_key_field = inputs.get_data_dictionary_args()  # noqa

    # create a data frame from the excel sheet & reset the index to iterate through the rows
    df = pd.read_excel(data_dictionary, sheet_name=xls_sheet_name, skiprows=2).fillna("").reset_index()

    logger.debug(df)
    # create a list to store the col_name/description pairs
    list_col_name_description_pairs = []

    for index, row in df.iterrows():

        # store column values in dedicated vars
        col_name = row[f"{col_name_field}"].upper()
        description = row[f"{description_field}"]
        primary_key = row[f"{primary_key_field}"]
        created_at = row[f"{created_at_field}"]
        updated_at = row[f"{updated_at_field}"]
        unique = row[f"{unique_field}"]
        not_null = row[f"{not_null_field}"]
        accepted_values = row[f"{accepted_values_field}"]
        fk_constraint_table = row[f"{fk_constraint_table_field}"]
        fk_constraint_key = row[f"{fk_constraint_key_field}"]

        # add this row's contents as a set to the list
        list_col_name_description_pairs.append(
            [col_name, description, primary_key, created_at, updated_at, unique, not_null, accepted_values, fk_constraint_table, fk_constraint_key]
        )
        logger.debug(list_col_name_description_pairs)

    return list_col_name_description_pairs


def main():
    """Main orchestration routine"""

    # fetch inputs from the config file
    env, data_src, src_snowflake_db, src_db_schema, data_dictionary, xls_sheet_names, target_op_src_filename = inputs.get_ips_for_src_properties()

    # first write the 'header' of the source.yml file
    # fmt: off
    rendered_schema_header = jinja_env_source.get_template("source_header.yml.j2").render(
        data_src=data_src, env=env, src_db=src_snowflake_db, src_db_schema=src_db_schema)
    # fmt: on

    # make the target dir if it doesn't exist
    target_dir = f"op/{data_src}/"
    logger.debug(f"target_dir = {target_dir}")
    verify_dir_exists(target_dir)

    # setup the file path for the op_file
    op_sources_file = os.path.join(target_dir, target_op_src_filename)

    with open((op_sources_file), "w") as op_src_file:
        op_src_file.write(f"{rendered_schema_header}\n")

    # extract data from each XLS sheet
    for xls_sheet in xls_sheet_names:

        # create a column name/description pairs and store these in a list
        list_col_name_description_pairs = read_xls_file(data_dictionary, xls_sheet)
        logger.debug(list_col_name_description_pairs)

        # render the table name to the (dbt) source.yml file
        rendered_schema_tbl = jinja_env_source.get_template("source_table.yml.j2").render(src_tbl_name=xls_sheet)

        logger.info(f"generate dbt source properties for the table: {xls_sheet}")

        # use each col_name/description pair to generate the (dbt) source.yml file, using a jinja template
        sum_rendered_table_pairs_op = generate_source_properties_for_table(list_col_name_description_pairs)

        # write the output to (dbt) source.yml file
        with open((op_sources_file), "a+") as op_src_file:
            # first write the table-level details
            op_src_file.write(f"{rendered_schema_tbl}")
            # followed by the col_name-description pairs
            op_src_file.write(f"{sum_rendered_table_pairs_op}\n")

    return


if __name__ == "__main__":

    # call the main orchestration function
    main()
