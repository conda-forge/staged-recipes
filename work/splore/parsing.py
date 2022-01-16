import base64
import json
import re
from collections import defaultdict
from typing import List, Optional, Tuple, Type, TypeVar, Union

from splore.models import Cursor, Page, RangeFilter, SortBy

_T = TypeVar("_T", bound=Union[Type[float], Type[int]])

PAGE_REGEX = r"^(next|prev)\(([^)]+)\)$"
SORT_REGEX = r"^(desc|asc)\(([^)]+)\)$"
FILTER_REGEX = r"^(le|lt|gt|ge)\(([^)]+)\)$"


def encode_base64(value: str) -> str:
    return base64.urlsafe_b64encode(value.encode()).decode().rstrip("=")


def parse_base64(value: str) -> str:

    value_padding = 4 - (len(value) % 4)
    value = value + ("=" * value_padding)

    return base64.urlsafe_b64decode(value).decode()


def encode_cursor(value: Cursor) -> str:
    return encode_base64(json.dumps(value))


def parse_cursor(value: str) -> Cursor:
    cursor = json.loads(parse_base64(value))
    return tuple(cursor) if isinstance(cursor, list) else cursor


def encode_page(value: Page) -> str:
    encoded_cursor = encode_cursor(value[0])
    return f"{value[1]}({encoded_cursor})"


def parse_page(page: Optional[str]) -> Page:

    if page is None:
        return None, "next"

    direction, encoded_cursor = re.match(PAGE_REGEX, page).groups()
    cursor = parse_cursor(encoded_cursor)

    return cursor, direction


def encode_sort_by(sort_by: SortBy) -> str:
    return f"{sort_by[1]}({sort_by[0]})"


def parse_sort_by(sort_by: Optional[str]) -> Optional[SortBy]:

    if sort_by is None:
        return None

    direction, column = re.match(SORT_REGEX, sort_by).groups()
    return column, direction


def encode_range_filter(range_filter: RangeFilter) -> List[str]:

    encoded_filters = []

    if range_filter.le is not None:
        encoded_filters.append(f"le({range_filter.le})")
    if range_filter.lt is not None:
        encoded_filters.append(f"lt({range_filter.lt})")
    if range_filter.gt is not None:
        encoded_filters.append(f"gt({range_filter.gt})")
    if range_filter.ge is not None:
        encoded_filters.append(f"ge({range_filter.ge})")

    return encoded_filters


def parse_range_filter(
    filters: List[str], value_type: _T
) -> Tuple[Optional[_T], Optional[_T], Optional[_T], Optional[_T]]:

    value_by_sign = defaultdict(list)

    for filter_str in filters:

        sign, value_str = re.match(FILTER_REGEX, filter_str).groups()
        value: _T = value_type(value_str)

        value_by_sign[sign.lower()].append(value)

    max_gt = None if len(value_by_sign["gt"]) == 0 else max(value_by_sign["gt"])
    max_ge = None if len(value_by_sign["ge"]) == 0 else max(value_by_sign["ge"])

    if max_ge is not None and max_gt is not None:

        if max_ge > max_gt:
            max_gt = None
        else:
            max_ge = None

    min_lt = None if len(value_by_sign["lt"]) == 0 else min(value_by_sign["lt"])
    min_le = None if len(value_by_sign["le"]) == 0 else min(value_by_sign["le"])

    if min_le is not None and min_lt is not None:

        if min_le > min_lt:
            min_lt = None
        else:
            min_le = None

    return min_le, min_lt, max_gt, max_ge
