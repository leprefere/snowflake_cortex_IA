import os
from snowflake.core import Root
from snowflake.snowpark import Session

CONNECTION_PARAMETERS = {
	"account": os.environ["SNOWFLAKE_ACCOUNT"],
	"user": os.environ["SNOWFLAKE_USER"],
	"password": os.environ["SNOWFLAKE_PASSWORD"],
	"role": "test_role",
	"warehouse": "test_warehouse",
	"database": "COFFEE_SHOP_DB",
	"schema": "PUBLIC",
}

session = Session.builder.configs(CONNECTION_PARAMETERS).create()
root = Root(session)

my_service = (root
	.databases["COFFEE_SHOP_DB"]
	.schemas["PUBLIC"]
	.cortex_search_services["PRODUCT_SEARCH_SVC"]
)

resp = my_service.search(
	query="< query here>",
	columns=["DESCRIPTION"],
	limit=10,
)

print(resp.to_json())
