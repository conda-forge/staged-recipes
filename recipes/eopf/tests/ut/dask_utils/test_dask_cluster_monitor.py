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
import time

import pytest

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")
pytest.importorskip("distributed")

from eopf.dask_utils import dask_helpers
from eopf.dask_utils.dask_cluster_type import ClusterType
from eopf.dask_utils.dask_context_manager import DaskContext
from eopf.dask_utils.dask_cluster_monitor import (
    ClusterState,
    DaskClusterMonitor,
)


@pytest.fixture(scope="function")
def dask_local():
    with DaskContext(
            cluster_type=ClusterType.LOCAL,
            cluster_config={
                "memory_limit": "1GiB",
                "n_workers": 2,
                "threads_per_worker": 1,
                "processes": True,
            },
            client_config={"timeout": "320s"},
    ) as ctx:
        print(f"DASK Context : {ctx}")
        yield ctx


@pytest.mark.unit
def test_nominal(dask_local):
    monitor = DaskClusterMonitor()
    monitor.check()
    fufut = dask_helpers.compute(da.random.randint(0, 100, size=(500, 500), chunks=(125, 125)))
    assert monitor.check() == ClusterState.RUNNING
    dask_helpers.wait_and_get_results(fufut)
    assert monitor.check() == ClusterState.RUNNING


@pytest.mark.unit
def test_failures(dask_local):
    monitor = DaskClusterMonitor(grace_period=15)
    monitor.check()
    fufut = dask_helpers.compute(da.random.randint(0, 100, size=(500000, 500000), chunks=(125000, 125000)))
    assert monitor.check() == ClusterState.RUNNING
    found = False
    for i in range(600):
        print(monitor.check())
        if ClusterState.FAILURES in monitor.check():
            found = True
            break
        time.sleep(1)
    dask_helpers.cancel_futures(fufut)
    for i in range(600):
        if fufut[0].cancelled():
            found = True
            break
    assert found
