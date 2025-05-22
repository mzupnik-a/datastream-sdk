import datetime
import logging
import uuid
from typing import List, Any

import azure.functions

import run_aggregations

logger = logging.getLogger(__name__)


class AzureFunctionAggregator:

    def __init__(self, data: azure.functions.InputStream):
        self._data: azure.functions.InputStream = data

    def process(self) -> List[Any]:
        result: List = run_aggregations.main(None, self._data, cloud="azure")
        result = self.transform_for_cosmos_db(result)
        result = self.remove_unique_visitors(result)

        return result

    @staticmethod
    def transform_for_cosmos_db(result) -> List:
        """
        Transform the aggregation result for Cosmos DB.
        """
        processed_result: List = []
        for item in result:
            unique_visitors_value: Any = item.get("unique_visitors_value")
            logline_date: datetime = datetime.datetime.fromtimestamp(item.get("start_timestamp")).date().isoformat()

            for visitor in unique_visitors_value:
                user_agent, client_ip = visitor
                last_octet = client_ip.split('.')[-1]
                partition_key_value = f"{logline_date}_{last_octet}"
                document = {
                    "id": str(uuid.uuid4()),
                    "partition_key": partition_key_value,
                    "date": logline_date,
                    "last_octet": last_octet,
                    "unique_visitor_value": [(user_agent, client_ip)]
                }
                processed_result.append(document)
        return processed_result

    @staticmethod
    def remove_unique_visitors(data: List[Any]) -> List[Any]:
        """
        removes unique_visitors_value from the list of dictionary, since we don't require this.
        """
        logger.info(f"remove_unique_visitors input length: {len(data)}")

        new_data = [dict(item) for item in data]
        for item in new_data:
            item.pop("unique_visitors_value", None)
        return new_data


def main(input_stream: azure.functions.InputStream,
         result_doc: azure.functions.Out[azure.functions.DocumentList]) -> None:
    logger.info(
        f"Python blob trigger function processing blob \n"
        f"Name: {input_stream.name}\n"
        f"Blob Size: {input_stream.length} bytes"
    )

    # Transform the input stream
    transformer: AzureFunctionAggregator = AzureFunctionAggregator(input_stream)
    result: List[Any] = transformer.process()

    # Write to Cosmos DB using result_doc
    result_doc.set(azure.functions.DocumentList(result))
