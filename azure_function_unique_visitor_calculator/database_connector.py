import logging
import os
from typing import Dict, Any, List

from azure.core.paging import ItemPaged
from azure.cosmos.container import ContainerProxy
from azure.cosmos.cosmos_client import CosmosClient
from azure.cosmos.database import DatabaseProxy

logger = logging.getLogger(__name__)


class DatabaseConnector:

    def __init__(self) -> None:
        self._cosmos_db_database_name = DatabaseConnector._get_env_variable("AzureCosmosDBName")
        self._cosmos_db_container_name = DatabaseConnector._get_env_variable("AzureCosmosDBContainerName")
        self._cosmos_db_connection_string = DatabaseConnector._get_env_variable("AzureCosmosDBConnectionString")

        logger.info(
            f"Database connection details:\n"
            f"AzureCosmosDBName: {self._cosmos_db_database_name}\n"
            f"AzureCosmosDBContainerName: {self._cosmos_db_container_name}")

    @staticmethod
    def _get_env_variable(var_name: str) -> str:
        try:
            return os.environ[var_name]
        except KeyError:
            raise KeyError(f"Environment variable '{var_name}' not found.")

    def _get_db_connection(self) -> ContainerProxy:
        client: CosmosClient = CosmosClient.from_connection_string(self._cosmos_db_connection_string)
        database: DatabaseProxy = client.get_database_client(self._cosmos_db_database_name)
        container: ContainerProxy = database.get_container_client(self._cosmos_db_container_name)
        return container

    def get_unique_visitors(self, logline_date_list: List[str]) -> Dict[str, int]:
        """
        Retrieves the unique visitor count for a list of logline dates.

        :param logline_date_list: A list of logline dates to query.
        :return: A dictionary mapping each logline date to its unique visitor count.
        """
        response: Dict[str, int] = {}
        logging.info(f"Fetching unique visitor counts for dates: {logline_date_list}")

        container: ContainerProxy = self._get_db_connection()

        for logline_date in logline_date_list:
            query: str = (
                f"SELECT VALUE COUNT(1) FROM {self._cosmos_db_container_name} c "
                f"JOIN (SELECT DISTINCT CONCAT(val[0], ',', val[1]) "
                f"FROM c JOIN val IN c.unique_visitor_value WHERE c.date = @logline_date)"
            )
            parameters: List[Dict[str, Any]] = [{"name": "@logline_date", "value": logline_date}]
            logging.info(f"Executing query for logline_date: {logline_date}")

            query_result: ItemPaged[Dict[str, Any]] = container.query_items(
                query={"query": query, "parameters": parameters},
                enable_cross_partition_query=True
            )
            total_visitors: List[Dict[str, Any]] = list(query_result)

            if total_visitors:
                logging.info(f"Unique visitor count for {logline_date}: {total_visitors[0]}")
                response[logline_date] = int(total_visitors[0])
            else:
                logging.info(f"No unique visitors found for {logline_date}")
                response[logline_date] = 0

        return response
