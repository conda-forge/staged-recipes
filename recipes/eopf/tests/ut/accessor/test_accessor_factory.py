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
from typing import Optional

import pytest

from eopf.accessor.accessor_factory import EOAccessorRegistry
from eopf.exceptions import AccessorNotDefinedError


@pytest.mark.unit
@pytest.mark.parametrize(
    "file, format, params",
    [("truc.nc", "netcdf", {}), ("truc.nc", None, {})],
)
def test_get_accessor(file: str, format: Optional[str], params: dict):
    accessor = EOAccessorRegistry.get_accessor_class(file, format)(file, **params)
    assert accessor is not None


@pytest.mark.unit
def test_list_accessors():
    list_accessor = EOAccessorRegistry.list_accessors()
    assert len(list_accessor) != 0


@pytest.mark.unit
@pytest.mark.parametrize(
    "file, format, params",
    [("truc.jp2", "jp2truc", {}), ("truc.machinbidule", None, {})],
)
def test_accessor_factory_errors(file: str, format: Optional[str], params: dict):
    with pytest.raises(AccessorNotDefinedError):
        EOAccessorRegistry.get_accessor_class(file, format)(file, **params)
