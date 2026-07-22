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
from pathlib import Path
from typing import Optional, Tuple
from unittest import mock

import pytest

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")

from eopf.common.file_utils import AnyPath
from eopf.config.config import EOConfiguration
from eopf.dask_utils import dask_helpers
from eopf.dask_utils.dask_cluster_type import ClusterType
from eopf.dask_utils.dask_context_manager import DaskContext
from eopf.dask_utils.dask_context_utils import init_from_eo_configuration
from eopf.exceptions.errors import (
    DaskClusterNotFound,
    DaskClusterTimeout,
    TriggeringConfigurationError,
)


@pytest.fixture
def dask_local(OUTPUT_DIR):
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 2,
            "threads_per_worker": 1,
            "processes": True,
            "scheduler_port": 0,
            "dashboard_address": 0,  # random dashboard port
        },
        client_config={"timeout": "320s"},
        performance_report_file=Path(OUTPUT_DIR) / "test-dask-report.html",
    ) as ctx:
        print(f"DASK Context : {ctx}")
        yield ctx


@pytest.mark.unit
def test_nominal(dask_local):
    assert dask_helpers.is_distributed()
    assert dask_helpers.get_distributed_client() is not None


@pytest.mark.unit
def test_performance_report(OUTPUT_DIR):
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 2,
            "threads_per_worker": 1,
            "processes": True,
            "scheduler_port": 0,
            "dashboard_address": 0,  # random dashboard port
        },
        client_config={"timeout": "320s"},
        performance_report_file=Path(OUTPUT_DIR) / "test-dask-report.html",
    ) as ctx:
        print(f"DASK Context : {ctx}")
        # some dask computation
        x = dask.array.arange(10, chunks=10)
        x.sum().compute()

    assert (Path(OUTPUT_DIR) / "test-dask-report.html").is_file()
    (AnyPath(OUTPUT_DIR) / "test-dask-report.html").rm()


@pytest.mark.unit
def test_task_stream_report(OUTPUT_DIR):
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 2,
            "threads_per_worker": 1,
            "processes": True,
            "scheduler_port": 0,
            "dashboard_address": 0,
        },
        client_config={"timeout": "320s"},
        task_stream_file=Path(OUTPUT_DIR) / "test-task-stream.html",
    ) as ctx:
        print(f"DASK Context : {ctx}")
        x = dask.array.arange(100, chunks=10)
        x.sum().compute()

    assert (Path(OUTPUT_DIR) / "test-task-stream.html").is_file()
    print(Path(OUTPUT_DIR) / "test-task-stream.html")
    (AnyPath(OUTPUT_DIR) / "test-task-stream.html").rm()


@pytest.mark.unit
def test_export_memory_sampler_csv(OUTPUT_DIR):
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 2,
            "threads_per_worker": 1,
            "processes": True,
            "scheduler_port": 0,
            "dashboard_address": 0,  # random dashboard port
        },
        client_config={"timeout": "320s"},
        memory_sampler_file=Path(OUTPUT_DIR) / "test-dask_sampler.csv",
        memory_sampler_config={"interval": 0.25, "measures": ["process", "managed"]},
    ) as ctx:
        print(f"DASK Context : {ctx}")
        # some dask computation
        x = dask.array.arange(100, chunks=10)
        x.sum().compute()

    process_csv_path = Path(OUTPUT_DIR) / "test-dask_sampler_dask_context_process.csv"
    managed_csv_path = Path(OUTPUT_DIR) / "test-dask_sampler_dask_context_managed.csv"
    assert process_csv_path.is_file()
    assert managed_csv_path.is_file()

    process_csv_content = process_csv_path.read_text(encoding="utf-8")
    managed_csv_content = managed_csv_path.read_text(encoding="utf-8")
    assert "timestamp" in process_csv_content
    assert "dask_context_process" in process_csv_content
    assert "dask_context_process_mib" in process_csv_content
    assert "dask_context_managed" not in process_csv_content
    assert ",," not in process_csv_content
    assert "timestamp" in managed_csv_content
    assert "dask_context_managed" in managed_csv_content
    assert "dask_context_managed_mib" in managed_csv_content
    assert "dask_context_process" not in managed_csv_content
    assert ",," not in managed_csv_content
    print(managed_csv_content)
    print(process_csv_content)
    (AnyPath(OUTPUT_DIR) / process_csv_path.name).rm()
    (AnyPath(OUTPUT_DIR) / managed_csv_path.name).rm()


@pytest.mark.unit
def test_local_cluster_without_dashboard():
    with DaskContext(
        cluster_type=ClusterType.LOCAL,
        cluster_config={
            "memory_limit": "1GiB",
            "n_workers": 1,
            "threads_per_worker": 1,
            "processes": False,
            "dashboard_address": None,
            "worker_dashboard_address": None,
            "scheduler_kwargs": {"dashboard": False},
        },
        client_config={"timeout": "320s"},
    ) as ctx:
        print(f"DASK Context : {ctx}")
        # some dask computation
        x = dask.array.arange(10, chunks=10)
        x.sum().compute()


@pytest.mark.gateway
def test_gateway():
    dask_gateway_address = os.getenv("DASK_GATEWAY__ADDRESS")
    jupyterhub_api_token = os.getenv("JUPYTERHUB_API_TOKEN")
    if dask_gateway_address is None or jupyterhub_api_token is None:
        raise Exception("Missing DASK_GATEWAY__ADDRESS or JUPYTERHUB_API_TOKEN")
    with DaskContext(
        cluster_type=ClusterType.GATEWAY,
        cluster_config={
            "address": dask_gateway_address,
            "auth": {"type": "jupyterhub", "api_token": jupyterhub_api_token},
            "worker_memory": 1,
            "n_workers": 1,
        },
        client_config={"timeout": "320s"},
        connect_timeout=600,
        wait_for_workers=True,
        wait_timeout=800,
        wait_raises=True,
    ) as ctx:
        print(f"DASK Context : {ctx}")


class FakeCluster:
    def __init__(self, name: str):
        self.adapted: Optional[Tuple[int, int]] = None
        self.scaled_to = 0
        self.name = name
        self.status = "running"
        self.started_time: Optional[float] = None

    def scale(self, n: int):
        self.scaled_to = n

    def adapt(self, minimum: int, maximum: int):
        self.adapted = (minimum, maximum)
        self.scaled_to = maximum

    def __enter__(self):
        self.started_time = time.time()
        return self

    def __exit__(self, *args):
        pass

    def close(self):
        pass

    def scheduler_info(self):
        """Simulate workers arriving over time"""
        if self.started_time is None:
            return {"workers": {}}

        elapsed = time.time() - self.started_time
        num_workers = min(int(elapsed // 2), self.scaled_to)

        # Return mock workers
        workers = {f"tcp://worker-{i}:1234": {"name": f"worker-{i}"} for i in range(num_workers)}
        return {"workers": workers}


class FakeClient:
    def __init__(self, *args, **kwargs):
        self.status = "running"
        self.started_time = None
        self.cluster = "dummy_cluster"
        self.forward_logging_calls = []
        self.register_plugin_calls = []
        self.unregister_worker_plugin_calls = []

    def __enter__(self):
        self.started_time = time.time()
        return self

    def __exit__(self, *args):
        pass

    def close(self):
        pass

    def register_plugin(self, *args, **kwargs):
        self.register_plugin_calls.append((args, kwargs))

    def dashboard_link(self, *args, **kwargs):
        return "42 "

    def processing(self, *args, **kwargs):
        return "42 "

    def unregister_worker_plugin(self, name, nanny=None):
        self.unregister_worker_plugin_calls.append((name, nanny))

    def forward_logging(self, logger_name=None, level=0):
        self.forward_logging_calls.append((logger_name, level))

    def scheduler_info(self):
        """Simulate workers arriving over time"""
        if self.started_time is None:
            return {"workers": {}}

        elapsed = time.time() - self.started_time
        # add a worker each second
        num_workers = int(elapsed // 1)

        # Return mock workers
        workers = {f"tcp://worker-{i}:1234": {"name": f"worker-{i}"} for i in range(num_workers)}
        return {"workers": workers}


@pytest.mark.unit
def test_gateway_mock():
    # Create mock cluster
    mock_cluster = FakeCluster("foobar")

    # Create mock gateway
    mock_gateway = mock.MagicMock()

    def slow_connect(*args, **kwargs):
        time.sleep(3)

    def slow_new_cluster(*args, **kwargs):
        time.sleep(3)
        return mock_cluster

    mock_gateway.connect.side_effect = slow_connect
    mock_gateway.new_cluster.side_effect = slow_new_cluster
    mock_gateway.new_cluster.__name__ = "mocker_new"
    mock_gateway.list_clusters.return_value = [
        FakeCluster(name="foo1"),
        FakeCluster(name="foo2"),
    ]

    client = FakeClient()
    with mock.patch("eopf.dask_utils.dask_context_manager.Client", return_value=client):
        with mock.patch("dask_gateway.Gateway", return_value=mock_gateway):
            with mock.patch(
                "eopf.dask_utils.dask_helpers.get_distributed_client",
                return_value=client,
            ):
                with DaskContext(
                    cluster_type=ClusterType.GATEWAY,
                    cluster_config={
                        "address": "dummy_address",
                        "auth": {"type": "jupyterhub", "api_token": "dummy_token"},
                        "image": "registry.eopf.copernicus.eu/cpm/eopf-cpm:latest",
                        "worker_memory": 4,
                        "n_workers": 4,
                    },
                    client_config={"timeout": "320s"},
                    connect_timeout=60,
                ) as ctx:
                    print(f"DASK Context : {ctx}")

                with pytest.raises(DaskClusterNotFound):
                    with DaskContext(
                        cluster_type=ClusterType.GATEWAY,
                        cluster_config={
                            "address": "dummy_address",
                            "reuse_cluster": "dummy_address",
                        },
                        client_config={"timeout": "320s"},
                    ) as ctx:
                        print(f"DASK Context : {ctx}")

                with pytest.raises(DaskClusterTimeout):
                    with DaskContext(
                        cluster_type=ClusterType.GATEWAY,
                        cluster_config={
                            "address": "dummy_address",
                        },
                        client_config={"timeout": "320s"},
                        connect_timeout=1,
                    ) as ctx:
                        print(f"DASK Context : {ctx}")

                with pytest.raises(DaskClusterTimeout):
                    with DaskContext(
                        cluster_type=ClusterType.GATEWAY,
                        cluster_config={
                            "address": "dummy_address",
                            "n_workers": 400,
                        },
                        client_config={"timeout": "320s"},
                        wait_for_workers=True,
                        wait_timeout=1,
                    ) as ctx:
                        print(f"DASK Context : {ctx}")


@pytest.mark.unit
def test_address_cluster_success():
    ctx = DaskContext(
        cluster_type=ClusterType.ADDRESS,
        client_config={"address": "tcp://scheduler:8786"},
    )
    # _setup_address_cluster doesn't create a cluster, just checks config
    assert ctx._cluster is None
    assert ctx._cluster_type == ClusterType.ADDRESS


@pytest.mark.unit
def test_forward_worker_logger_level_is_forwarded():
    client = FakeClient()

    with mock.patch("eopf.dask_utils.dask_context_manager.Client", return_value=client):
        with DaskContext(
            cluster_type=ClusterType.ADDRESS,
            client_config={"address": "tcp://scheduler:8786"},
            forward_worker_logger="distributed.worker",
            forward_worker_logger_level=20,
        ):
            pass

    assert client.forward_logging_calls == [("distributed.worker", 20)]


@pytest.mark.unit
def test_auto_gc_plugin_is_registered_by_default():
    client = FakeClient()

    with mock.patch("eopf.dask_utils.dask_context_manager.Client", return_value=client):
        with DaskContext(
            cluster_type=ClusterType.ADDRESS,
            client_config={"address": "tcp://scheduler:8786"},
        ):
            pass

    assert client.register_plugin_calls
    assert client.register_plugin_calls[0][1]["name"] == "auto-gc"
    assert client.unregister_worker_plugin_calls == [("auto-gc", None)]


@pytest.mark.unit
def test_auto_gc_plugin_can_be_disabled():
    client = FakeClient()

    with mock.patch("eopf.dask_utils.dask_context_manager.Client", return_value=client):
        with DaskContext(
            cluster_type=ClusterType.ADDRESS,
            client_config={"address": "tcp://scheduler:8786"},
            auto_gc=False,
        ):
            pass

    assert client.register_plugin_calls == []
    assert client.unregister_worker_plugin_calls == []


@pytest.mark.unit
def test_wait_options_are_explicit_dask_context_options():
    with mock.patch("eopf.dask_utils.dask_context_manager.LocalCluster") as local_cluster:
        ctx = DaskContext(
            cluster_type=ClusterType.LOCAL,
            cluster_config={"n_workers": 1, "dashboard_address": None},
            wait_for_workers=True,
            wait_timeout=12,
            wait_raises=False,
            connect_timeout=34,
        )

    local_cluster.assert_called_once_with(n_workers=1, dashboard_address=None)
    assert ctx._wait_workers is True
    assert ctx._wait_timeout == 12
    assert ctx._wait_raises is False
    assert ctx._connect_timeout == 34


@pytest.mark.unit
def test_wait_options_in_cluster_config_are_not_interpreted():
    with mock.patch("eopf.dask_utils.dask_context_manager.LocalCluster") as local_cluster:
        ctx = DaskContext(
            cluster_type=ClusterType.LOCAL,
            cluster_config={"n_workers": 1, "wait_for_workers": True},
        )

    local_cluster.assert_called_once_with(n_workers=1, wait_for_workers=True)
    assert ctx._wait_workers is False


@pytest.mark.unit
def test_address_cluster_missing_address():
    with pytest.raises(TriggeringConfigurationError):
        DaskContext(cluster_type=ClusterType.ADDRESS, client_config={})


@pytest.mark.unit
def test_init_from_eo_configuration_forwards_task_stream_and_memory_sampler(tmp_path):
    conf = EOConfiguration()
    conf.clear_loaded_configurations()
    conf.load_dict(
        {
            "dask_context__cluster_type": "local",
            "dask_context__task_stream_file": str(tmp_path / "task-stream.html"),
            "dask_context__memory_sampler_file": str(tmp_path / "memory.csv"),
            "dask_context__memory_sampler_config__interval": 0.5,
            "dask_context__wait_for_workers": True,
            "dask_context__wait_timeout": 45,
            "dask_context__wait_raises": False,
            "dask_context__connect_timeout": 67,
            "dask_context__auto_gc": False,
        },
    )

    try:
        ctx = init_from_eo_configuration()
        assert ctx._task_stream_file == str(tmp_path / "task-stream.html")
        assert ctx._memory_sampler_file == tmp_path / "memory.csv"
        assert ctx._memory_sampler_config == {"interval": 0.5}
        assert ctx._wait_workers is True
        assert ctx._wait_timeout == 45
        assert ctx._wait_raises is False
        assert ctx._connect_timeout == 67
        assert ctx._auto_gc is False
        assert "interval" not in ctx._client_config
    finally:
        conf.clear_loaded_configurations()
