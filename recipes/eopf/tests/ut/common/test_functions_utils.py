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
import multiprocessing
import os
import tempfile
import time
import weakref
from enum import Flag, auto
from pathlib import Path
from typing import Any, Sized

import pytest

from eopf.common import functions_utils
from eopf.common.functions_utils import (
    AllowedMultiplicity,
    change_working_dir,
    compute_crc,
    is_last,
    nested_apply,
    not_none,
    parse_flag_expr,
    resolve_path_in_dict,
    safe_eval,
    verify_multiplicity,
)
from eopf.exceptions.errors import TimeOutError


@pytest.mark.unit
def test_nested_apply():
    in_dict = {"truc": {"bidule": 3}, "machin": 1}
    res_dict = {"truc": {"bidule": 6}, "machin": 2}
    out_dict = nested_apply(in_dict, lambda x: x * 2)
    assert out_dict == res_dict


@pytest.mark.unit
def test_not_none():
    with pytest.raises(TypeError):
        not_none(None)
    obj = 3
    assert not_none(obj) == obj


@pytest.mark.unit
@pytest.mark.parametrize(
    "data, expected",
    [
        ([1, 2, 3], [(1, False), (2, False), (3, True)]),
        ([], []),
        ((10, 20, 30), [(10, False), (20, False), (30, True)]),
        ([42], [(42, True)]),
        ((x for x in range(3)), [(0, False), (1, False), (2, True)]),
        ("abc", [("a", False), ("b", False), ("c", True)]),
    ],
)
def test_is_last(data, expected):
    result = list(is_last(data))
    assert result == expected


@pytest.mark.unit
def test_resolve_path_in_dict():
    in_dict = {"truc": {"bidule": 3}, "machin": 2}
    assert resolve_path_in_dict(in_dict, "truc/bidule") == 3
    with pytest.raises(KeyError):
        resolve_path_in_dict(in_dict, "truc/machin/chouette")


@pytest.mark.unit
@pytest.mark.parametrize(
    "formula, variables, modules, should_raise, result",
    [
        ("2", {}, {}, False, 2),
        ("__import__(os)", {}, {}, True, 2),
    ],
)
def test_safe_eval(formula, variables, modules, should_raise, result):
    if should_raise:
        with pytest.raises(ValueError):
            safe_eval(formula, variables, modules)
    else:
        assert safe_eval(formula, variables, modules) == result


class FlagsForTest(Flag):
    NONE = 0
    RUNNING = auto()
    PAUSED = auto()
    STUCK_SPILL = auto()
    STUCK_PROCESSING = auto()
    FAILURES = auto()
    NO_WORKERS = auto()
    OFFLINE = auto()


@pytest.mark.unit
@pytest.mark.parametrize(
    "data, expected",
    [
        ("RUNNING", FlagsForTest.RUNNING),
        ("PAUSED | STUCK_SPILL", FlagsForTest.PAUSED | FlagsForTest.STUCK_SPILL),
        ("NONE", FlagsForTest.NONE),
    ],
)
def test_parse_flag_expr(data, expected):
    assert parse_flag_expr(data, FlagsForTest) == expected


@pytest.mark.unit
def test_crc():
    nested_dict = {
        "properties": {
            "product:type": "S02MSIL1C",
            "processing:version": "04.00",
            "start_datetime": "2021-01-01T01:01:01",
            "end_datetime": "2021-01-01T01:01:01",
            "platform": "S2B",
            "sat:relative_orbit": 128,
            "product:timeliness_category": "NR",
            "product:timeliness": "PT3H",
        },
    }

    crc_result = compute_crc(nested_dict, digits=8)

    assert crc_result == "6D1010AD"

    crc_result = compute_crc(nested_dict, digits=3)

    assert crc_result == "0AD"


def slow_func(cluster_name: str, *, delay: float = 0.2, **kwargs: Any):
    if cluster_name is None:
        raise RuntimeError("cluster name can't be None")
    time.sleep(delay)
    return "OK"


class ClassWithWeakRef:
    def __init__(self):
        self.closed = False
        self._finalizer = weakref.finalize(self, self.close)
        ws = weakref.WeakSet()
        # This is the problematic closure
        self.func = ws._remove

    def close(self):
        self.closed = True

    def timit(self, cluster_name: str, **kwargs: Any):
        self.func(None)
        return slow_func(cluster_name, **kwargs)

    def timit_exc(self, cluster_name: str, **kwargs: Any):
        raise ValueError("cake is a lie")


@pytest.mark.unit
def test_run_with_timeout():
    cluster_config = {
        "address": "truc",
        "auth": {"type": "jupyterhub", "api_token": "the_token"},
        "image": "registry.eopf.copernicus.eu/cpm/eopf-cpm:latest",
        "worker_memory": 4,
        "n_workers": 8,
    }
    # multiprocessing.set_start_method("spawn", force=True)
    classwithweak = ClassWithWeakRef()

    with pytest.raises(TimeOutError):
        functions_utils.run_with_timeout(classwithweak.timit, 0.05, "doudidou", delay=0.2, **cluster_config)

    functions_utils.run_with_timeout(classwithweak.timit, 1, "doudidou", delay=0.01, **cluster_config)

    with pytest.raises(ValueError):
        functions_utils.run_with_timeout(classwithweak.timit_exc, 1, "doudidou", **cluster_config)

    print("Start method:", multiprocessing.get_start_method())


@pytest.mark.unit
@pytest.mark.parametrize(
    "value, multiplicity",
    [
        ([1], "exactly_one"),
        ([1, 2], "at_least_one"),
        ([1, 2, 3], "more_than_one"),
        ([1, 2, 3, 4], 4),
    ],
)
def test_verify_multiplicity(value: Sized, multiplicity: AllowedMultiplicity | int):
    verify_multiplicity(value, multiplicity)


@pytest.mark.unit
@pytest.mark.parametrize(
    "value, multiplicity",
    [
        ([], "exactly_one"),
        ([], "at_least_one"),
        ([1], "more_than_one"),
        ([1, 2], 4),
    ],
)
def test_verify_multiplicity_error(value: Sized, multiplicity: AllowedMultiplicity | int):
    with pytest.raises(ValueError):
        verify_multiplicity(value, multiplicity)


@pytest.mark.unit
@pytest.mark.parametrize(
    "payload_file",
    [
        "./payload.yaml",
        "payload.yaml",
        tempfile.gettempdir(),
        "tests/payload.yaml",
    ],
)
def test_change_working_dir(payload_file: str):
    payload_dir = Path(payload_file).parent
    print("dirname:")
    payload_dir.mkdir(exist_ok=True)
    os.path.dirname(payload_file)
    print("payload:")
    print(payload_file)
    print(payload_dir)
    working_dir = payload_dir
    expected = working_dir.resolve()
    with change_working_dir(working_dir):
        assert Path(os.getcwd()) == expected
