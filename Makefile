# Usage:
# make installations	# install the package for the first time, managing dependencies & performing a housekeeping cleanup too
# make deps		# just install the dependencies
# make install		# perform the end-to-end install
# make clean		# perform a housekeeping cleanup

.EXPORT_ALL_VARIABLES:

.PHONY = installations deps clean install get_ips initialise_dbt_project validate_src_db_connection install_packages gen_schema_w_codegen gen_dbt_sql_objs

CONFIG_FILE := ip/config.yaml
# the 2 vars below are just for formatting CLI message output
COLOUR_TXT_FMT_OPENING := \033[0;33m
COLOUR_TXT_FMT_CLOSING := \033[0m

installations: clean deps install

clean: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target 'clean'. Remove any redundant files, e.g. downloads.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	@# remove any dbt project files if they already exist
	@rm -rf ${DBT_PROJECT_NAME}

deps: get_ips
	@echo "----------------------------------------------------------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'deps'. Download the relevant pip package dependencies (note: ignore the pip depedency resolver errors.)${COLOUR_TXT_FMT_CLOSING}"
	@echo "----------------------------------------------------------------------------------------------------------------------"
	@pip3 install -q -r requirements.txt
	@pip3 uninstall keyring -qy && pip3 install keyring -q # there is a module conflict here that otherwise throws a warning
	@pip3 install --upgrade dbt-snowflake==${DBT_VERSION} -q

#############################################################################################
# 'install' & 'add_data_source' are the two main routines of this Makefile
#############################################################################################
install: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'install'. Run the setup and install targets.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	# Step 1:  Validate user inputs
	@make -s validate_user_ip
	# Step 2: remove any previously generated files
	@make -s clean
	# Step 3: Initialise the dbt project
	@make -s initialise_dbt_project
	@echo
	# Step 4: Verify connection to the source DB
	@make -s validate_src_db_connection
	@echo
	# Step 5: Install the desired dbt packages
	@make -s install_packages
	@echo
	# Step 6: 'Code Generation Workflow': Generate the dbt source.yml (source properties) file
	@make -s gen_source_properties_file
	@echo "--------------------------------"
	@echo
	# Step 7: 'Code Generation Workflow': Generate the snapshot/incremental .sql files using Jinja templates
	@echo
	@make -s gen_dbt_sql_objs
	# Step 8: Change permissions of the dbt project folder. Otherwise you run into perms issues with the logs/ & target/ folders
	@chmod -R 777 ${DBT_PROJECT_NAME}
	# Step 9: Tmp (demo only) - copy over the the dbt project '${DBT_PROJECT_NAME}' to the Airflow DAGS repo
	# NOTE: 'copy_dbt_project_to_af_dags_dir' is only used to accelerate local Airflow/dbt development. Consider commenting out the call
	@make -s copy_dbt_project_to_af_dags_dir
	@echo -e "\n------------------------------------------------------------------"
	@echo "Finished! Check the newly created dbt project folder: '${DBT_PROJECT_NAME}'"
	@echo -e "------------------------------------------------------------------\n"

add_data_source: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'add_data_source'. Use this to add a new data source to your dbt project.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	# validate the target dbt project exists
	@if [ ! -d "${DBT_PROJECT_NAME}" ]; then echo -e "\nError: Target dbt project '${DBT_PROJECT_NAME}' does not exist.\n"; exit 1; fi
	# validate user inputs
	@make -s validate_user_ip
	# create a target dir in the dbt project for the new data source
	@mkdir ${DBT_PROJECT_NAME}/models/${DBT_MODEL}/${DATA_SRC}
	# 'Code Generation Workflow': Generate the dbt source.yml (source properties) file
	@make -s gen_source_properties_file
	@echo "--------------------------------"
	@echo
	# 'Code Generation Workflow': Generate the snapshot/incremental .sql files using Jinja templates
	@echo
	@make -s gen_dbt_sql_objs
	@make -s copy_dbt_project_to_af_dags_dir
	@echo -e "\n------------------------------------------------------------------"
	@echo "Finished! Check the newly created dbt project folder: '${DBT_PROJECT_NAME}'"
	@echo -e "------------------------------------------------------------------\n"

#############################################################################################
# Setup/validation targets: 'get_ips' & 'validate_user_ip'
#############################################################################################
get_ips:
	@# Target: 'get_ips'. Get input args from ip/config.yaml
	@# general params
	$(eval ENV=$(shell yq -r '.general_params.env | select( . != null )' ${CONFIG_FILE}))
	$(eval AF2_DAGS_PATH=$(shell yq -r '.general_params.abs_path_to_airflow2_dags | select( . != null )' ${CONFIG_FILE}))
	$(eval DATA_SRC=$(shell yq -r '.data_src_params.data_src | select( . != null )' ${CONFIG_FILE}))
	@# db_connection params
	$(eval SNOWFLAKE_ACCOUNT=$(shell yq -r '.db_connection_params.snowflake_account' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_USERNAME=$(shell yq -r '.db_connection_params.snowflake_username | select( . != null )' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_PRIVATE_FILE=$(shell yq -r '.db_connection_params.abs_path_to_snowflake_private_key | select( . != null )' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_WH=$(shell yq -r '.db_connection_params.snowflake_warehouse' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_ROLE=$(shell yq -r '.db_connection_params.snowflake_role' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_DB=$(shell yq -r '.db_connection_params.snowflake_data_src_db' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_DB=$(shell yq -r '.db_connection_params.snowflake_src_db' ${CONFIG_FILE}))
	$(eval SNOWFLAKE_SCHEMA=$(shell yq -r '.db_connection_params.snowflake_src_db_schema' ${CONFIG_FILE}))
	@# dbt params
	$(eval DBT_VERSION=$(shell yq -r '.dbt_params.dbt_version' ${CONFIG_FILE}))
	$(eval DBT_PROFILE_NAME=$(shell yq -r '.dbt_params.dbt_profile_name' ${CONFIG_FILE}))
	$(eval DBT_PROJECT_NAME=$(shell yq -r '.dbt_params.dbt_project_name' ${CONFIG_FILE}))
	$(eval DBT_MODEL=$(shell yq -r '.dbt_params.dbt_model' ${CONFIG_FILE}))
	$(eval PROGRAM=$(shell yq -r '.dbt_params.program' ${CONFIG_FILE}))

validate_user_ip: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'validate_user_ip'. Validate the user inputs.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	# INFO: 1) Verify the user has provided a value for the key 'data_src' in ip/config.yaml
	@[ "${DATA_SRC}" ] || ( echo -e "\nError: 'data_src' key is empty in ip/config.yaml\n"; exit 1 )
	# INFO: 2) Verify the user has provided a value for the key 'snowflake_username' in ip/config.yaml
	@[ "${SNOWFLAKE_USERNAME}" ] || ( echo -e "\nError: 'snowflake_username' key is empty in ip/config.yaml\n"; exit 1 )
	# INFO: 3) Verify the user has provided a value for the key 'snowflake_private_key' in ip/config.yaml
	@[ "${SNOWFLAKE_PRIVATE_FILE}" ] || ( echo -e "\nError: 'snowflake_private_key' key is empty in ip/config.yaml\n"; exit 1 )
	# INFO: 4) Verify the user has provided a value for the key 'abs_path_to_airflow2_dags' in ip/config.yaml
	@[ "${AF2_DAGS_PATH}" ] || ( echo -e "\nError: 'abs_path_to_airflow2_dags' key is empty in ip/config.yaml\n"; exit 1 )

#############################################################################################
# Targets used for dbt project setup
#############################################################################################
initialise_dbt_project: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'initialise_dbt_project'. Initialise the dbt project.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	@[ "${DBT_PROJECT_NAME}" ] || ( echo "\nError: DBT_PROJECT_NAME variable is not set\n"; exit 1 )
	# Step 1: Initialise the dbt project. dbt project name = '${DBT_PROJECT_NAME}'.
	@echo
	dbt init ${DBT_PROJECT_NAME} --skip-profile-setup
	@echo
	# Step 2: copy profiles, macros & prereq dirs into dbt project folder
	# TODO - delete the 2 lines below
	@mkdir ${DBT_PROJECT_NAME}/models/${DBT_MODEL}
	@mkdir ${DBT_PROJECT_NAME}/models/integration
	@make -s copy_templates_into_dbt_project
	@echo
	# Step 3: Generate the profiles.yml, dbt_project.yml and README files
	@j2 ${DBT_PROJECT_NAME}/profiles/profiles.yml.j2 -o ${DBT_PROJECT_NAME}/profiles/profiles.yml
	@rm -r ${DBT_PROJECT_NAME}/models/example && rm ${DBT_PROJECT_NAME}/README.md
	@j2 templates/jinja_templates/dbt_project.yml.j2 -o ${DBT_PROJECT_NAME}/dbt_project.yml
	@j2 templates/jinja_templates/README.md.j2 -o ${DBT_PROJECT_NAME}/README.md
	# Step 4: rename files/folders in the dbt models directory
	@python3 py/gen_dbt_model_directory.py
	@echo

copy_templates_into_dbt_project: get_ips
	@cp -r templates/template_dirs/docs/ ${DBT_PROJECT_NAME}/docs/
	@cp -r templates/template_dirs/logs/ ${DBT_PROJECT_NAME}/logs/
	@cp -r templates/template_dirs/macros/ ${DBT_PROJECT_NAME}/macros/
	# TODO - remove integration from the below
	@cp -r templates/template_dirs/models/ ${DBT_PROJECT_NAME}/models/integration
	@cp -r templates/template_dirs/profiles/ ${DBT_PROJECT_NAME}/profiles/
	@cp -r templates/template_dirs/style_guides/ ${DBT_PROJECT_NAME}/style_guides/
	@cp -r templates/template_dirs/target/ ${DBT_PROJECT_NAME}/target/
	@cp -r templates/template_dirs/tests/ ${DBT_PROJECT_NAME}/tests/
	@cp templates/packages.yml ${DBT_PROJECT_NAME}
	@cp -f templates/.gitignore ${DBT_PROJECT_NAME}
	@cp templates/.pre-commit-config.yaml ${DBT_PROJECT_NAME}
	@cp templates/.sqlfluff ${DBT_PROJECT_NAME}
	@cp templates/.sqlfluffignore ${DBT_PROJECT_NAME}

#############################################################################################
# dbt command targets
#############################################################################################
validate_src_db_connection: get_ips
	@echo "-----------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'validate_src_db_connection'. Verify connection to the source DB.${COLOUR_TXT_FMT_CLOSING}"
	@echo "-----------------------------------------------------------------------"
	@echo
	cd ${DBT_PROJECT_NAME} && dbt debug --profiles-dir=profiles --profile=local_${DBT_PROFILE_NAME}

install_packages: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'install_packages'. Install the desired dbt packages.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	@cd ${DBT_PROJECT_NAME} && dbt deps --profiles-dir=profiles

run_model: get_ips
	@echo "------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'run_model'. Run the dbt model.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------"
	@cd ${DBT_PROJECT_NAME} && dbt run --profiles-dir profiles --models ${DBT_MODEL}

#############################################################################################
# Python 'code generation' targets
#############################################################################################
gen_source_properties_file: get_ips
	@echo "-----------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'gen_source_properties_file'. Generate the dbt source.yml (source properties) file.${COLOUR_TXT_FMT_CLOSING}"
	@echo "-----------------------------------------------------------------------"
	@python3 py/gen_dbt_src_properties.py
	@# create dir if not exists
	#@cp op/${DATA_SRC}/_${DATA_SRC}_source.yml ${DBT_PROJECT_NAME}/models/${DBT_MODEL}/
	#TODO - uncomment the below & then delete the above
	@cp op/${DATA_SRC}/_${DATA_SRC}_source.yml ${DBT_PROJECT_NAME}/models/staging/${DBT_PROJECT_NAME}/

gen_schema_w_codegen: get_ips
	# TODO: troubleshoot this
	@echo "--------------------------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'gen_schema_w_codegen'. Generate the dbt schema.yml file using dbt-codegen.${COLOUR_TXT_FMT_CLOSING}"
	@echo "--------------------------------------------------------------------------------------"
	cd ${DBT_PROJECT_NAME} && dbt run-operation generate_source --args '{"schema_name": "shared", "database_name": "${DATA_SRC}_dev", "name": "${DATA_SRC}", "generate_columns": "true", "include_descriptions": "true"}' --profiles-dir=profiles > schema.yml
	@echo -e "version: 2\n" > ${DBT_PROJECT_NAME}/models/schema.yml
	@tail -n +5 ${DBT_PROJECT_NAME}/schema.yml >> ${DBT_PROJECT_NAME}/models/schema.yml
	@rm ${DBT_PROJECT_NAME}/schema.yml

gen_dbt_sql_objs: get_ips
	@echo "-------------------------------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target: 'gen_dbt_sql_objs'. Generate snapshot/incremental .sql files using Jinja templates.${COLOUR_TXT_FMT_CLOSING}"
	@echo "-------------------------------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}# Generate sql for the 'snapshots' layer.${COLOUR_TXT_FMT_CLOSING}"
	@echo "---------------------------------------------------------------"
	@python3 py/gen_dbt_sql_objs.py snapshot
	@echo "---------------------------------------------------------------"
	@mkdir ${DBT_PROJECT_NAME}/snapshots/${DATA_SRC}/
	@cp -R op/${DATA_SRC}/snapshot/*.sql ${DBT_PROJECT_NAME}/snapshots/${DATA_SRC}
	@echo -e "${COLOUR_TXT_FMT_OPENING}# Generate sql for the 'incremental' layer.${COLOUR_TXT_FMT_CLOSING}"
	@echo "---------------------------------------------------------------"
	@python3 py/gen_dbt_sql_objs.py incremental
	@cp -R op/${DATA_SRC}/incremental/*.sql ${DBT_PROJECT_NAME}/models/staging/${DBT_PROJECT_NAME}/
	#TODO - uncomment the below & then delete the above
	#@cp -R op/${DATA_SRC}/incremental/*.sql ${DBT_PROJECT_NAME}/models/${DBT_MODEL}

copy_dbt_project_to_af_dags_dir: get_ips
	@echo "------------------------------------------------------------------------------------------"
	@echo -e "${COLOUR_TXT_FMT_OPENING}Target 'demo'. For demo purposes only, copy over the the dbt project '${DBT_PROJECT_NAME}' to the Airflow DAGS repo and change required perms/copy required files.${COLOUR_TXT_FMT_CLOSING}"
	@echo "------------------------------------------------------------------------------------------"
	# copy over the dbt project to the Airflow DAGs repo.
	# If a dbt project of the same name already exists in the AF dags repo, add a '_bkp' suffix to the dbt project in the AF dags repo
	@if test -d ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME}; \
	then echo "# INFO: dbt project '${DBT_PROJECT_NAME}' folder already exists in ${AF2_DAGS_PATH}/dbt/." \
	&& echo "Rename existing dbt project and copy the generated dbt project into target Airflow DAGs repo." \
	&& mv ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME} ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME}_bkp \
	&& cp -R ${DBT_PROJECT_NAME} ${AF2_DAGS_PATH}/dbt/; \
	else echo "# INFO: dbt project repo does not exist in the AF DAGs repo. Copy the dbt project over." \
	&& cp -R ${DBT_PROJECT_NAME} ${AF2_DAGS_PATH}/dbt/; \
	fi
	@chmod -R 777 ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME}/logs
	@chmod -R 777 ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME}/target
	# copy the user's RSA key path into the dbt profiles dir
	@cp ${SNOWFLAKE_PRIVATE_FILE} ${AF2_DAGS_PATH}/dbt/${DBT_PROJECT_NAME}/profiles/
