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

from eopf.common import path_utils


@pytest.mark.unit
def test_join_path():
    assert path_utils.join_path("truc", "machin") == "truc/machin"
    assert path_utils.join_path("truc", "machin", sep=":") == "truc:machin"


@pytest.mark.unit
def test_regex_path_append():
    assert path_utils.regex_path_append("truc", "/machin") == "truc/machin"
    assert path_utils.regex_path_append(None, "machin") == "machin"
    assert path_utils.regex_path_append("truc", None) == "truc"
    assert path_utils.regex_path_append("truc/", "/machin") == "truc/machin"


@pytest.mark.unit
def test_remove_specific_extension():
    assert (
        path_utils.remove_specific_extensions(
            "truc.zarr.truc.bidule",
            [
                ".bidule",
            ],
        )
        == "truc.zarr.truc"
    )


@pytest.mark.unit
def test_add_extension():
    assert path_utils.add_extension("machin", ".zarrt") == "machin.zarrt"
