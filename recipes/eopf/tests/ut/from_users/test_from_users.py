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
from typing import Any

import pytest
import yaml
from xarray import DataTree

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")

from eopf.common.temp_utils import EOLocalTemporaryFolder
from eopf.dask_utils.dask_cluster_type import ClusterType
from eopf.dask_utils.dask_context_manager import DaskContext


@pytest.mark.unit
def test_empty_product(EMBEDED_TEST_DATA_FOLDER_UNIT):
    trigger_filename = "trigger.yaml"
    filepath = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "triggering", trigger_filename)

    class Test:
        def __init__(self) -> None:
            self.eoproduct = DataTree(name="test")

        def parallel_load(self, urls):
            load = dask.delayed(self.load_yaml_file)
            buffer = []
            for url in urls:
                json_str = load(url)
                buffer.append(json_str)
            # json_str = dask.compute(buffer)
            return buffer

        def load_yaml_file(self, file_name: str) -> dict[str, Any]:
            with open(file_name) as f:
                data = yaml.safe_load(f)
            return data

    with DaskContext(cluster_type=ClusterType.LOCAL):
        test = Test()
        urls = [filepath] * 5
        delay = test.parallel_load(urls)
        print(dask.compute(delay))
    # Deactivate automatic 'dask.distributed' scheduler search as this one is deactivated
    dask.config.set(scheduler=None)


@pytest.mark.unit
@pytest.mark.parametrize("processor", ["MW1", "SR1", "SM2_HY", "SM2_LI", "SM2_SI"])
def test_local_temp_disappear(processor):
    my_temp_folder_obj = EOLocalTemporaryFolder().get()
    assert my_temp_folder_obj.exists()
