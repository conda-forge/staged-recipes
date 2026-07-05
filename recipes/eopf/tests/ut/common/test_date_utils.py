#
# Copyright (C) 2026 CS Group
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import datetime
from typing import Union

import pytest
import pytz

from eopf.common import date_utils
from eopf.common.date_utils import convert_to_unix_time


@pytest.mark.unit
@pytest.mark.parametrize(
    "utcstr, result",
    [
        (
            "UTC=2021-04-02T01:01:01.053Z",
            datetime.datetime(2021, 4, 2, 1, 1, 1, 53000),
        ),
        (
            "UTC=2021-04-02T01:01:01.053",
            datetime.datetime(2021, 4, 2, 1, 1, 1, 53000),
        ),
        (
            "UTC=2021-04-02T01:01:01",
            datetime.datetime(2021, 4, 2, 1, 1, 1),
        ),
        (
            "2021-04-02T01:01:01.053Z",
            datetime.datetime(2021, 4, 2, 1, 1, 1, 53000),
        ),
        (
            "2021-04-02T01:01:01.053",
            datetime.datetime(2021, 4, 2, 1, 1, 1, 53000),
        ),
        (
            "2021-04-02T01:01:01",
            datetime.datetime(2021, 4, 2, 1, 1, 1),
        ),
    ],
)
def test_get_datetime_from_utc(utcstr: str, result: datetime.datetime):
    assert date_utils.get_datetime_from_utc(utcstr) == result


@pytest.mark.unit
def test_convert_unix_time():
    import pytz

    # Define datetime-like string and verify if conversion match with datetime object and expected unix time. (MS)
    string_date = "2020-03-31T17:19:29.230522Z"
    dt_date = datetime.datetime(2020, 3, 31, 17, 19, 29, 230522, pytz.UTC)
    expected_unix_time = 1585675169230522

    assert convert_to_unix_time(string_date) == convert_to_unix_time(dt_date) == expected_unix_time

    # Define datetime-like string in Zulu Time Zone, and verify that it doesnt match with expected unix time
    string_date = "2020-03-31T17:19:29.230522GMT-3"
    assert convert_to_unix_time(string_date) != convert_to_unix_time(dt_date)
    assert convert_to_unix_time(string_date) != expected_unix_time

    #
    try:
        string_date = "a string that is not a valid date"
        convert_to_unix_time(string_date)
    except ValueError:
        assert True


@pytest.mark.unit
@pytest.mark.parametrize(
    "datestr, result",
    [
        (
            "20210402T010101",
            datetime.datetime(2021, 4, 2, 1, 1, 1),
        ),
    ],
)
def test_get_datetime_from_yyyymmddthhmmss(datestr: str, result: datetime.datetime):
    assert date_utils.get_datetime_from_yyyymmddthhmmss(datestr) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "datestr, result",
    [
        (
            "20210402",
            datetime.datetime(2021, 4, 2, 0, 0),
        ),
    ],
)
def test_get_datetime_from_yyyymmdd(datestr: str, result: datetime.datetime):
    assert date_utils.get_datetime_from_yyyymmdd(datestr) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "datet, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            "2021-10-01T01:01:01Z",
        ),
    ],
)
def test_get_utc_from_datetime(datet: datetime.datetime, result: str):
    assert date_utils.get_utc_from_datetime(datet) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            2459488.5423726854,
        ),
    ],
)
def test_get_julianday_as_double(p_tm: datetime.datetime, result: float):
    assert date_utils.get_julianday_as_double(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            2459488,
        ),
    ],
)
def test_get_julianday_as_int(p_tm: datetime.datetime, result: int):
    assert date_utils.get_julianday_as_int(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "ptimestartutc, ptimestoputc, result",
    [
        (
            "UTC=2021-04-02T01:01:01.053Z",
            "UTC=2021-04-02T01:01:01.053Z",
            2459306.5423732987,
        ),
    ],
)
def test_get_average_time(ptimestartutc: str, ptimestoputc: str, result: float):
    assert date_utils.get_average_julian_day(ptimestartutc, ptimestoputc) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            "20211001",
        ),
    ],
)
def test_get_date_yyyymmdd_from_tm(p_tm: datetime.datetime, result: str):
    assert date_utils.get_date_yyyymmdd_from_tm(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            "20211001T010101",
        ),
    ],
)
def test_get_date_yyyymmddthhmmss_from_tm(p_tm: datetime.datetime, result: str):
    assert date_utils.get_date_yyyymmddthhmmss_from_tm(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1),
            "20211001",
        ),
    ],
)
def test_get_date_hhmmss_from_tm(p_tm: datetime.datetime, result: str):
    assert date_utils.get_date_yyyymmdd_from_tm(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "p_tm, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1, microsecond=53000),
            "053",
        ),
    ],
)
def test_get_date_millisecs_from_tm(p_tm: datetime.datetime, result: str):
    assert date_utils.get_date_millisecs_from_tm(p_tm) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "result",
    [
        (datetime.datetime(1970, 1, 1, 0, 0, tzinfo=pytz.UTC)),
    ],
)
def test_get_min_datetime_for_timestamp(result: datetime.datetime):
    assert date_utils.get_min_datetime_for_timestamp() == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "date, result",
    [
        (
            datetime.datetime(year=2021, month=10, day=1, hour=1, minute=1, second=1, tzinfo=pytz.UTC),
            1633050061000000,
        ),
        (
            "2021-04-02T01:01:01.053Z",
            1617325261053000,
        ),
    ],
)
def test_convert_to_unix_time_bis(date: Union[str, datetime.datetime], result: Union[str, int]):
    print(convert_to_unix_time(date))
    print(result)
    assert convert_to_unix_time(date) == result
