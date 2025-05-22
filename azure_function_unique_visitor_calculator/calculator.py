import json
import logging
from datetime import datetime, timedelta, timezone
from typing import Any, List, Dict

from azure.functions import HttpRequest, HttpResponse

from azure_function_unique_visitor_calculator.database_connector import DatabaseConnector

logger = logging.getLogger(__name__)


class UniqueVisitorCalculator:

    def __init__(self, request: HttpRequest) -> None:
        self._request: HttpRequest = request

    def process(self) -> HttpResponse:
        logger.info("Unique visitor function is triggered on a http request")
        try:
            req_body: Any = self._parse_json(self._request)
            from_date: str = self._get_from_date(req_body)
            to_date: str = self._get_to_date(req_body)

            date_list: List[str] = self._get_date_list(from_date, to_date)
        except Exception as e:
            return HttpResponse(str(e), status_code=400)

        database_connector: DatabaseConnector = DatabaseConnector()
        result: Dict[str, int] = database_connector.get_unique_visitors(date_list)

        json_str = json.dumps(result)
        return HttpResponse(json_str, mimetype="application/json")

    @staticmethod
    def _parse_json(request: HttpRequest) -> Any:
        try:
            req_body = request.get_json()
        except ValueError as e:
            raise Exception("Invalid JSON request body") from e
        return req_body

    @staticmethod
    def _get_from_date(req_body: Any) -> str:
        from_date: str = req_body.get("from_date")
        if not from_date:
            raise Exception("Request body should contain 'from_date'")
        return from_date

    @staticmethod
    def _get_to_date(req_body: Any) -> str:
        to_date: str = req_body.get("to_date")
        if not to_date:
            raise Exception("Request body should contain 'to_date'")
        return to_date

    @staticmethod
    def _get_date_list(from_date: str, to_date: str) -> List[str]:
        logging.info(f"Get list of date from {from_date} and {to_date}.")

        date_format = "%Y-%m-%d"

        # from_date and to_date cannot be empty
        if not from_date or not to_date:
            raise Exception("Error: from_date and to_date cannot be empty")

        # validate the date format
        try:
            start_date = datetime.strptime(from_date, date_format)
            end_date = datetime.strptime(to_date, date_format)
        except ValueError as e:
            raise Exception(
                "Error: from_date or to_date has an invalid date format. Please enter the date in the format "
                "of YYYY-MM-DD.") from e

        # to_date cannot be less than from_date
        if end_date < start_date:
            raise Exception("Error: to_date cannot be less than from_date")

        # get today's date
        today = datetime.now(timezone.utc)

        # to_date cannot be later than today
        if end_date > today:
            raise Exception("Error: to_date cannot be later than today.")

        delta = end_date - start_date
        days_diff = delta.days

        # The difference between the from_date and to_date should not be more than 90 days
        if days_diff > 90:
            raise Exception("Error: The difference between the from_date and to_date should not be more than 90 days.")

        start_day_delta = today - start_date

        # from_date should not more than 90 days old
        if start_day_delta > timedelta(days=90):
            raise Exception("Error: from_date should not more than 90 days old.")

        date_list: List[str] = []
        while start_date <= end_date:
            date_list.append(start_date.strftime(date_format))
            start_date += timedelta(days=1)

        date_list.reverse()

        logger.info(f"logline date list :: {date_list}")

        return date_list
