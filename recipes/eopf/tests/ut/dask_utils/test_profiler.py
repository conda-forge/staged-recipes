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
from pathlib import Path

import pytest

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")
delayed = pytest.importorskip("dask").delayed

from eopf.common.file_utils import AnyPath
from eopf.exceptions import SingleThreadProfilerError
from eopf.tracing import single_thread_profiler


@pytest.mark.unit
def test_single_threaded_profiler_nominal(OUTPUT_DIR):
    """Test nominal functioning of the single_thread_profiler"""
    expected_return_type = int
    expected_parameter_value = 2
    report_path = Path(OUTPUT_DIR) / "single-thread-report"

    @single_thread_profiler(
        report_name=report_path,
    )
    def just_a_simple_dask_func(a_parameter: int):
        # test parameters are passed correctly
        assert isinstance(a_parameter, int) and a_parameter == expected_parameter_value

        # some dask computation
        x = da.random.random((1000, 1000), chunks=(250, 250))

        # Do some operations (transpose, multiply, mean)
        y = (x + x.T).dot(x).mean()

        # Trigger computation
        y.compute()

        return 100

    # test that the decorated function returns a Stats object
    assert isinstance(just_a_simple_dask_func(expected_parameter_value), expected_return_type)

    # test that the report was saved on disk
    assert report_path.is_file()
    AnyPath(str(report_path)).rm()


def slow_add(x, y):
    # A tiny artificial delay so it shows up in profiling
    total = x + y
    for _ in range(10000):
        total += 1
        total -= 1
    return total


def small_dask_delayed_workload():
    # Build a small task graph
    values = [delayed(slow_add)(i, i + 1) for i in range(5)]
    total = delayed(sum)(values)
    return total.compute()


@pytest.mark.unit
def test_single_threaded_profiler_delayed(OUTPUT_DIR):
    """Test nominal functioning of the single_thread_profiler"""
    expected_return_type = int
    report_path = Path(OUTPUT_DIR) / "single-thread-report-delayed"

    @single_thread_profiler(report_name=report_path)
    def test_profile_delayed():
        result = small_dask_delayed_workload()
        assert result > 0
        return result

    # test that the decorated function returns a Stats object
    assert isinstance(test_profile_delayed(), expected_return_type)

    # test that the report was saved on disk
    assert report_path.is_file()
    AnyPath(str(report_path)).rm()


@pytest.mark.unit
def test_single_threaded_profiler_print(OUTPUT_DIR):
    """Test nominal functioning of the single_thread_profiler"""
    expected_return_type = int
    expected_parameter_value = 2

    @single_thread_profiler(limit=25, sort_by="ncalls")
    def just_a_simple_dask_func(a_parameter: int):
        # test parameters are passed correctly
        assert isinstance(a_parameter, int) and a_parameter == expected_parameter_value

        # some dask computation
        x = da.random.random((1000, 1000), chunks=(250, 250))

        # Do some operations (transpose, multiply, mean)
        y = (x + x.T).dot(x).mean()

        # Trigger computation
        y.compute()

        return 100

    # test that the decorated function returns a Stats object
    assert isinstance(just_a_simple_dask_func(expected_parameter_value), expected_return_type)


@pytest.mark.unit
def test_single_thread_profiler_raises_exception(OUTPUT_DIR):
    """Test that SingleThreadProfilerError is raised when the decorated function raises an exception"""

    @single_thread_profiler(
        report_name=Path(OUTPUT_DIR) / "single-thread-report",
    )
    def just_a_simple_dask_func():
        raise SingleThreadProfilerError("Just an exception")

    # test that an Exception is raised
    with pytest.raises(SingleThreadProfilerError):
        _ = just_a_simple_dask_func()
