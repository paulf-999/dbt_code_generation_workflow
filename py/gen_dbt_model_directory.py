#!/usr/bin/env python3
"""
Python Version  : 3.8
* Name          : gen_dbt_model_directory.py
* Description   : Generates a boilerplate dbt model file/folder structure using config inputs.
* Created       : 13-10-2022
* Usage         : python3 gen_dbt_model_directory.py
"""

__author__ = "Paul Fry"
__version__ = "1.0"

import os
import inputs

working_dir = os.getcwd()
data_src, dbt_project_name = inputs.get_ips_for_gen_dbt_model_directory()

dbt_models_dir = os.path.join(working_dir, dbt_project_name, "models")
string_patterns = ["<data_src>", "<dbt_project>"]


def process_sub_dir_paths(dbt_models_dir, string_patterns):

    sub_dirs = []

    for path, dirs, files in os.walk(dbt_models_dir):
        for subdir in dirs:
            sub_dirs.append(os.path.join(path, subdir))

    for sub_dir in sub_dirs:
        for pattern in string_patterns:
            if pattern in sub_dir:
                rename_dbt_model_paths(pattern, sub_dir)


def process_file_paths(dbt_models_dir, string_patterns):

    models_dir_files = []

    for path, dirs, files in os.walk(dbt_models_dir):
        for name in files:
            models_dir_files.append(os.path.join(path, name))

    for file in models_dir_files:
        filename = os.path.basename(file)

        for pattern in string_patterns:
            if pattern in filename:
                rename_dbt_model_paths(pattern, file)


def rename_dbt_model_paths(pattern, path):

    data_src, dbt_project_name = inputs.get_ips_for_gen_dbt_model_directory()

    if pattern == "<data_src>":
        new_path = path.replace("<data_src>", data_src)
        os.rename(path, new_path)
    elif pattern == "<dbt_project>":
        new_path = path.replace("<dbt_project>", dbt_project_name)
        os.rename(path, new_path)

    return


if __name__ == "__main__":
    """This is executed when run from the command line"""

    # perform the directory name substitutions
    process_sub_dir_paths(dbt_models_dir, string_patterns)

    # perform file name substitutions
    process_file_paths(dbt_models_dir, string_patterns)
