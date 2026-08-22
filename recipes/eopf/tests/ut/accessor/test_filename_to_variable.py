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

import pytest
from xarray import DataArray

from eopf.accessor.filename_to_variable import (
    FilenameToVariableAccessor,
    PathToAttrAccessor,
)


@pytest.mark.unit
def test_filename_to_variable(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    accessor = FilenameToVariableAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT,
        ),
    )
    try:
        accessor.open()
        with pytest.raises(TypeError):
            accessor[""] = DataArray()

    finally:
        accessor.close()


@pytest.mark.unit
def test_path_to_attr(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    accessor = PathToAttrAccessor(
        os.path.join(
            EMBEDED_TEST_DATA_FOLDER_UNIT, "filename_to_variable", "path_to_attr", "DATASTRIP",
            "filename.xml",
        ),
    )
    accessor.open()
    try:
        print(str(accessor.get_data("").attrs))
        assert accessor.get_data("").attrs["datastrip"] == "filename.xml"
        with pytest.raises(NotImplementedError):
            accessor.write_attrs("", {})
        with pytest.raises(TypeError):
            accessor[""] = DataArray()
        with pytest.raises(TypeError):
            del accessor[""]
    finally:
        accessor.close()


@pytest.mark.unit
def test_path_to_attr_errors():
    accessor = PathToAttrAccessor(
        os.path.join("DATASTRIP", "filename.xml"),
    )

    with pytest.raises(TypeError):
        accessor[""]
    accessor.open()
    with pytest.raises(TypeError):
        accessor[""]
    with pytest.raises(TypeError):
        accessor["truc"]
