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

import pytest

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")

from eopf.dask_utils.dask_cluster_type import ClusterType


@pytest.mark.unit
def test_supported_cluster_types_are_local_gateway_and_address():
    assert {cluster_type.value for cluster_type in ClusterType} == {"local", "gateway", "address"}


@pytest.mark.unit
def test_cluster_type_can_be_built_from_value():
    assert ClusterType("local") is ClusterType.LOCAL


@pytest.mark.unit
@pytest.mark.parametrize(
    "removed_cluster_type",
    ["ssh", "kubernetes", "pbs", "sge", "lsf", "slurm", "yarn", "custom"],
)
def test_removed_cluster_types_are_rejected(removed_cluster_type):
    with pytest.raises(ValueError):
        ClusterType(removed_cluster_type)
