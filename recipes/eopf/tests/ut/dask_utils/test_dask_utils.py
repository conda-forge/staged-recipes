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
import os
import time
from types import SimpleNamespace
from unittest import mock

import pytest

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")
pytest.importorskip("distributed")

from eopf.common.file_utils import AnyPath
from eopf.dask_utils import dask_helpers
from eopf.dask_utils.dask_cluster_type import ClusterType
from eopf.dask_utils.dask_context_manager import DaskContext
from eopf.dask_utils.dask_helpers import (
    ImmediateFuture,
    cancel_futures,
    clear_computation_interrupt,
    compute,
    computation_interrupted,
    get_distributed_client,
    get_computation_interrupt_event,
    is_distributed,
    is_worker_reachable,
    scatter,
    signal_computation_interrupt,
    wait_and_get_results,
)
from eopf.exceptions.errors import DaskClusterTimeout, DaskComputingError


@pytest.mark.unit
def test_distributed_client_detection():
    assert get_distributed_client() is None
    assert not is_distributed()

    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "n_workers": 1,
            "threads_per_worker": 1,
        },
    ) as ctx:  # noqa
        assert get_distributed_client() is not None
        assert is_distributed()

    assert get_distributed_client() is None
    assert not is_distributed()


@pytest.mark.unit
def test_get_distributed_client_ignores_stale_client_without_scheduler():
    stale_client = SimpleNamespace(status="running", scheduler=None)

    with mock.patch("distributed.get_client", return_value=stale_client):
        assert get_distributed_client() is None


@pytest.mark.unit
def test_computation_interrupt_event_helpers(dask_context_threads):
    event = get_computation_interrupt_event()

    assert event is not None
    assert clear_computation_interrupt()
    assert not computation_interrupted()
    assert not computation_interrupted(event)
    assert signal_computation_interrupt()
    assert computation_interrupted()
    assert computation_interrupted(event)
    assert clear_computation_interrupt()
    assert not computation_interrupted()

    with mock.patch("eopf.dask_utils.dask_helpers.get_distributed_client", return_value=None):
        assert not computation_interrupted()


@pytest.mark.unit
def test_is_worker_reachable(EMBEDED_TEST_DATA_FOLDER_UNIT):
    trigger_filename = "trigger.yaml"
    path_obj = AnyPath(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "triggering", trigger_filename))
    assert is_worker_reachable(path_obj)

    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "n_workers": 4,
            "processes": True,
            "threads_per_worker": 1,
        },
    ) as ctx:  # noqa
        assert is_worker_reachable(path_obj)


@pytest.mark.unit
def test_is_not_worker_reachable(EMBEDED_TEST_DATA_FOLDER_UNIT):
    trigger_filename = "trigger-false.yaml"
    path_obj = AnyPath(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "triggering", trigger_filename))
    assert not is_worker_reachable(path_obj)

    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "n_workers": 4,
            "processes": True,
            "threads_per_worker": 1,
        },
    ) as ctx:  # noqa
        assert not is_worker_reachable(path_obj)


@pytest.mark.unit
@pytest.mark.real_s3
def test_is_worker_reachable_s3(EMBEDED_TEST_DATA_FOLDER_UNIT, s3_output_test_data, s3_output_config_real):
    path_obj = AnyPath(f"{s3_output_test_data[0]}://{s3_output_test_data[1]}/", **s3_output_config_real)
    assert is_worker_reachable(path_obj)

    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "n_workers": 4,
            "processes": True,
            "threads_per_worker": 1,
        },
    ) as ctx:  # noqa
        assert is_worker_reachable(path_obj)


@pytest.mark.unit
@pytest.mark.real_s3
def test_is_not_worker_reachable_s3(EMBEDED_TEST_DATA_FOLDER_UNIT, s3_output_test_data, s3_output_config_real):
    path_obj = AnyPath(f"{s3_output_test_data[0]}://{s3_output_test_data[1]}/foobar", **s3_output_config_real)
    assert not is_worker_reachable(path_obj)

    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "n_workers": 4,
            "processes": True,
            "threads_per_worker": 1,
        },
    ) as ctx:  # noqa
        assert not is_worker_reachable(path_obj)


@pytest.mark.unit
def test_not_enough_workers():
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 4,
            "threads_per_worker": 1,
            "processes": True,
        },
        client_config={"timeout": "320s"},
    ) as ctx:
        print(f"DASK Context : {ctx}")
        with pytest.raises(DaskClusterTimeout):
            dask_helpers.wait_for_workers(10, 4)
        dask_helpers.wait_for_workers(1, 4)


@pytest.mark.unit
def test_compute_without_client_returns_futurelike_list():
    x = da.arange(10).sum()  # dask collection
    futures = compute(x)

    assert isinstance(futures, list)
    assert len(futures) == 1
    assert isinstance(futures[0], ImmediateFuture)

    # NOTE: current implementation does dask.compute([x]) => ([result],)
    # so FutureLike.value is the *list* of results
    assert futures[0].result() == [45]


@pytest.mark.unit
def test_wait_and_get_results_without_client_keeps_order():
    futures = [ImmediateFuture("a"), ImmediateFuture("b"), ImmediateFuture("c")]
    assert wait_and_get_results(futures) == ["a", "b", "c"]


@pytest.mark.unit
def test_scatter_without_client_returns_data():
    arr = da.ones((3, 3), chunks=(3, 3))
    out = scatter(arr)
    # no distributed client => returns data itself
    assert out is arr


@pytest.mark.unit
def test_worker_reachable_without_client(
    tmp_path,
):
    p = tmp_path / "file.txt"
    assert is_worker_reachable(p) is False
    p.write_text("x")
    assert is_worker_reachable(p) is True


@pytest.mark.unit
def test_compute_with_client_returns_real_futures(dask_context_threads):
    x = da.arange(10).sum()
    futures = compute(x)

    assert isinstance(futures, list)
    assert len(futures) == 1
    # Distributed Future has .key attribute (FutureLike doesn't)
    assert hasattr(futures[0], "key")

    res = wait_and_get_results(futures)
    assert res == [45]


@pytest.mark.unit
def test_wait_and_get_results_mixed_futurelike_and_future_keeps_order(dask_context_threads):
    f1 = ImmediateFuture("local")
    f2 = dask_context_threads.client.submit(lambda: "remote")
    f3 = ImmediateFuture("local2")

    res = wait_and_get_results([f1, f2, f3])
    assert res == ["local", "remote", "local2"]


@pytest.mark.unit
def test_wait_and_get_results_raises_on_future_error(dask_context_threads):
    ok = dask_context_threads.client.submit(lambda: 123)
    boom = dask_context_threads.client.submit(lambda: 1 / 0)

    with pytest.raises(DaskComputingError):
        wait_and_get_results([ok, boom], cancel_at_first_error=True)


@pytest.mark.unit
def test_cancel_futures_with_client(dask_context_threads):
    # Create a "long" task so it can be cancelled deterministically
    def sleepy():
        time.sleep(5)
        return 1

    fut = dask_context_threads.client.submit(sleepy)
    cancel_futures([fut], force=True)

    # Depending on timing, it may end as "cancelled" or sometimes "error"/"finished" if too fast,
    # but in practice with sleep it should cancel.
    assert fut.cancelled() or fut.status in {"cancelled", "error"}


@pytest.mark.unit
def test_scatter_with_client_returns_future(dask_context_threads):
    arr = da.ones((4, 4), chunks=(2, 2))
    out = scatter(arr)

    # With client => should be a distributed future
    assert hasattr(out, "result")
    # Make sure it's usable
    got = out.result()
    assert got.shape == (4, 4)
