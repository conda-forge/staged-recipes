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

from eopf.common.file_utils import AnyPath
from eopf.exceptions.errors import MissingArgumentsMappingFormatterError
from eopf.store.mapping_manager import EOPFMappingManager, IsOptionalFormater


@pytest.mark.unit
@pytest.mark.parametrize(
    "product_path, product_type",
    [
        pytest.param("S3_OL_1_ZIP_unit", "S03OLCEFR", marks=pytest.mark.need_files),
        pytest.param("S2_MSIL2A_unit", "S02MSIL2A", marks=pytest.mark.need_files),
        ("FAKE_S2_MSIL0_unit", "S02MSIRAW"),
        ("FAKE_S1_IW_SLC_unit", "S01SIWSLC"),
    ],
    indirect=["product_path"],
)
def test_get_mapping(product_path: str, product_type: str):
    """Test get valid mapping"""

    mf = EOPFMappingManager()
    mf_mapping = mf.parse_mapping(product_url=product_path, product_type=product_type)
    assert mf_mapping is not None

    shortnames = mf.parse_shortnames(product_url=product_path, product_type=product_type)
    assert shortnames is not None


@pytest.mark.unit
def test_mapping_manager_error():
    mf = EOPFMappingManager()
    mf_product_url, mf_mapping, mf_shorts = mf.parse_mapping(product_url="truc", product_type="bidule")
    assert mf_product_url is None
    assert mf_mapping is None
    assert mf_shorts is None


@pytest.mark.unit
def test_mapping_manager_rejects_anypath_mapping_path():
    with pytest.raises(TypeError, match="not AnyPath"):
        EOPFMappingManager(mapping_path=AnyPath("eopf/store/mapping"))  # type: ignore[arg-type]


@pytest.fixture
def optional_formatter():
    return IsOptionalFormater()


# -----------------------------
# Test missing arguments
# -----------------------------
@pytest.mark.parametrize(
    "kwargs, missing_key",
    [
        ({"key": "a", "value": 1}, "eo_obj_description"),
        ({"eo_obj_description": {"a": 1}, "value": 1}, "key"),
        ({"eo_obj_description": {"a": 1}, "key": "a"}, "value"),
    ],
)
@pytest.mark.unit
def test_optional_missing_arguments(optional_formatter, kwargs, missing_key):
    with pytest.raises(MissingArgumentsMappingFormatterError) as excinfo:
        optional_formatter.format(**kwargs)
    assert missing_key in str(excinfo.value)


# -----------------------------
# Test when key exists and value differs
# -----------------------------
@pytest.mark.unit
def test_optional_key_exists_value_differs(optional_formatter):
    eo_obj_description = {"a": 42, "b": 99}
    key = "a"
    value = 0  # differs from eo_obj_description[key]

    result = optional_formatter.format(eo_obj_description=eo_obj_description, key=key, value=value)
    # Should return the original dict since value differs
    assert result == eo_obj_description


# -----------------------------
# Test when key missing in eo_obj_description
# -----------------------------
@pytest.mark.unit
def test_optional_key_not_in_eo_obj_description(optional_formatter):
    eo_obj_description = {"b": 99}
    key = "a"
    value = 0

    result = optional_formatter.format(eo_obj_description=eo_obj_description, key=key, value=value)
    # Key not present -> should return empty dict
    assert result == {}


# -----------------------------
# Test when key exists but value matches
# -----------------------------
@pytest.mark.unit
def test_optional_key_exists_value_matches(optional_formatter):
    eo_obj_description = {"a": 42, "b": 99}
    key = "a"
    value = 42  # matches

    result = optional_formatter.format(eo_obj_description=eo_obj_description, key=key, value=value)
    # Value matches -> should return empty dict
    assert result == {}


# -----------------------------
# Test with extra kwargs
# -----------------------------
@pytest.mark.unit
def test_optional_extra_kwargs_ignored(optional_formatter):
    eo_obj_description = {"a": 1}
    key = "a"
    value = 0

    result = optional_formatter.format(eo_obj_description=eo_obj_description, key=key, value=value, extra=123)
    # Should behave normally ignoring extra kwargs
    assert result == eo_obj_description
