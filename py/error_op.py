import logging

# Set up a specific logger with our desired output level
logging.basicConfig(format="%(message)s")
logger = logging.getLogger("application_logger")
logger.setLevel(logging.INFO)


def print_no_user_input_msg():
    """Write error output indicating no args have been provided"""
    logger.error("\nError: No input argument provided.\n")
    logger.error("Usage: python3 gen_dbt_sql_objs.py <ip_jinja_template_name>\n")
    logger.error("Available jinja templates are: 'snapshot' and 'incremental'.\n")
    logger.error("Example: python3 gen_dbt_sql_objs.py snapshot")
    raise SystemExit

    return


def print_invalid_user_input_msg(ip_jinja_template):
    """Write error output indicating that an invalid arg has been provided"""
    logger.error(f"\nError: Invalid input argument provided: '{ip_jinja_template}'.\n")
    logger.error("Usage: python3 gen_dbt_sql_objs.py <ip_jinja_template_name>\n")
    logger.error("Available jinja templates are: 'snapshot' and 'incremental'.\n")
    logger.error("Example: python3 gen_dbt_sql_objs.py snapshot")

    return
