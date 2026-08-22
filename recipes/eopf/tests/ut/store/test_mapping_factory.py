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

import json
from pathlib import Path
from tempfile import TemporaryDirectory

import pytest

from eopf.common.constants import EOPF_CPM_PATH
from eopf.common.file_utils import AnyPath
from eopf.common.file_utils import load_json_file
from eopf.config import EOConfiguration
from eopf.exceptions.errors import (
    MappingMissingError,
    MappingRegistrationError,
    MissingArgumentError,
)
import eopf.store.mapping_factory as mapping_factory_module
from eopf.store.mapping_factory import MAPPING_FILE_PATTERN, EOPFMappingFactory


@pytest.fixture
def mapping_factory_data_dir(EMBEDED_TEST_DATA_FOLDER_UNIT: Path) -> Path:
    return Path(EMBEDED_TEST_DATA_FOLDER_UNIT) / "mapping_factory"


@pytest.fixture
def versioned_mappings_dir(mapping_factory_data_dir: Path) -> Path:
    return mapping_factory_data_dir / "test_versioned_mappings"


@pytest.fixture
def valid_mapping_path(versioned_mappings_dir: Path) -> Path:
    return versioned_mappings_dir / "type_a_v1_map_v1.json"


@pytest.fixture
def normalization_product_dir(tmp_path: Path) -> Path:
    product_dir = tmp_path / "NORMALIZE_TYPEA_SAMPLE.SAFE"
    product_dir.mkdir()
    return product_dir


@pytest.fixture
def normalization_product_with_old_token(normalization_product_dir: Path) -> Path:
    (normalization_product_dir / "manifest.safe").write_text(
        "this manifest contains OLD_TOKEN",
        encoding="utf-8",
    )
    return normalization_product_dir


@pytest.fixture
def normalization_product_without_old_token(normalization_product_dir: Path) -> Path:
    (normalization_product_dir / "manifest.safe").write_text(
        "this manifest contains no expected token",
        encoding="utf-8",
    )
    return normalization_product_dir


@pytest.fixture
def overlapping_mappings_dir(mapping_factory_data_dir: Path) -> Path:
    return mapping_factory_data_dir / "test_overlapping_explicit_mappings"


@pytest.mark.unit
def test_init_default_mappings() -> None:
    """Test the registry of the default mappings."""
    mf = EOPFMappingFactory()
    default_mapping_path = EOConfiguration().get("mapping__default_folder")
    dir_path = Path(EOPF_CPM_PATH) / default_mapping_path
    expected_maps = set(dir_path.glob(MAPPING_FILE_PATTERN))
    mf_maps = {item.path for item in mf._mapping_set}
    assert expected_maps == mf_maps


@pytest.mark.unit
def test_init_dir_mappings(versioned_mappings_dir: Path) -> None:
    """Test init with user-given directory containing maps."""
    expected_maps = set(versioned_mappings_dir.glob(MAPPING_FILE_PATTERN))
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)
    mf_maps = {item.path for item in mf._mapping_set}
    assert expected_maps == mf_maps


@pytest.mark.unit
def test_init_dir_mappings_uses_cache(versioned_mappings_dir: Path, monkeypatch: pytest.MonkeyPatch) -> None:
    """Test repeated factory creation reuses registered mappings and loaded contents."""
    EOPFMappingFactory.clear_cache()
    load_count = 0
    original_load_json_file = mapping_factory_module.load_json_file

    def count_load_json_file(path: Path) -> dict:
        nonlocal load_count
        load_count += 1
        return original_load_json_file(path)

    monkeypatch.setattr(mapping_factory_module, "load_json_file", count_load_json_file)
    try:
        EOPFMappingFactory(mapping_path=versioned_mappings_dir)
        first_load_count = load_count

        EOPFMappingFactory(mapping_path=versioned_mappings_dir)

        assert first_load_count == len(list(versioned_mappings_dir.glob(MAPPING_FILE_PATTERN)))
        assert load_count == first_load_count
    finally:
        EOPFMappingFactory.clear_cache()


@pytest.mark.unit
def test_init_none_mappings() -> None:
    """Test init with None mapping path."""
    with pytest.raises(FileNotFoundError):
        EOPFMappingFactory(mapping_path=None)


@pytest.mark.unit
def test_init_mapping_path_rejects_anypath(valid_mapping_path: Path) -> None:
    """Mapping files are local-only and must use pathlib.Path or local path strings."""
    with pytest.raises(TypeError, match="not AnyPath"):
        EOPFMappingFactory(mapping_path=AnyPath(str(valid_mapping_path)))  # type: ignore[arg-type]


@pytest.mark.unit
def test_init_one_mapping(valid_mapping_path: Path) -> None:
    """Test init with only one mapping registered."""
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)
    mf_maps = {item.path for item in mf._mapping_set}
    assert mf_maps == {valid_mapping_path}


@pytest.mark.unit
def test_register_non_existing_dir(
    EMBEDED_TEST_DATA_FOLDER_UNIT: Path,
    valid_mapping_path: Path,
) -> None:
    """Test error is raised when trying to register a non-existing dir."""
    dir_path = Path(EMBEDED_TEST_DATA_FOLDER_UNIT) / "DOES_NOT_EXIST"
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)

    with pytest.raises(FileNotFoundError):
        mf._register_dir(dir_path)


@pytest.mark.unit
def test_register_non_existing_file(
    EMBEDED_TEST_DATA_FOLDER_UNIT: Path,
    valid_mapping_path: Path,
) -> None:
    """Test error is raised when trying to register a non-existing file."""
    file_path = Path(EMBEDED_TEST_DATA_FOLDER_UNIT) / "DOES_NOT_EXIST.json"
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)

    with pytest.raises(FileNotFoundError):
        mf._register_file(file_path)


@pytest.mark.unit
def test_register_empty_dir(valid_mapping_path: Path) -> None:
    """Test error is raised when trying to register an empty dir."""
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)

    with TemporaryDirectory() as empty_dir:
        empty_dir_path = Path(empty_dir)
        with pytest.raises(MappingRegistrationError):
            mf._register_dir(empty_dir_path)


@pytest.mark.unit
def test_register_map_with_no_recognition_section(
    mapping_factory_data_dir: Path,
    valid_mapping_path: Path,
) -> None:
    """Test error is raised when trying to register a map without recognition section."""
    map_path = mapping_factory_data_dir / "map_without_recognition.json"
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)

    with pytest.raises(MappingRegistrationError):
        mf._register_file(map_path)


@pytest.mark.unit
def test_register_map_with_no_recognition_methods(
    mapping_factory_data_dir: Path,
    valid_mapping_path: Path,
) -> None:
    """Test error is raised when trying to register a map without recognition methods."""
    map_path = mapping_factory_data_dir / "map_without_recognition_methods.json"
    mf = EOPFMappingFactory(mapping_path=valid_mapping_path)

    with pytest.raises(MappingRegistrationError):
        mf._register_file(map_path)


@pytest.mark.unit
def test_get_mapping_from_product_path_selects_latest_product_and_mapping_version(
    versioned_mappings_dir: Path,
) -> None:
    """When only product_path is provided, latest compatible processing_version and mapping_version are selected."""
    expected_mapping_path = versioned_mappings_dir / "type_a_v2_map_v2.json"
    expected_mapping = load_json_file(expected_mapping_path)

    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)
    mf_mapping = mf.get_mapping(product_path="TYPEA_SAMPLE.SAFE")

    assert expected_mapping == mf_mapping


@pytest.mark.unit
def test_get_mapping_explicit_product_type_selects_latest_product_and_mapping_version(
    versioned_mappings_dir: Path,
) -> None:
    """When only product_type is provided, latest processing_version and mapping_version are selected."""
    expected_mapping_path = versioned_mappings_dir / "type_a_v2_map_v2.json"
    expected_mapping = load_json_file(expected_mapping_path)

    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)
    mf_mapping = mf.get_mapping(product_type="TYPE_A")

    assert expected_mapping == mf_mapping


@pytest.mark.unit
def test_get_mapping_explicit_product_type_and_processing_version_selects_latest_mapping_version(
    versioned_mappings_dir: Path,
) -> None:
    """When product_type and processing_version are provided, latest mapping_version is selected."""
    expected_mapping_path = versioned_mappings_dir / "type_a_v1_map_v2.json"
    expected_mapping = load_json_file(expected_mapping_path)

    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)
    mf_mapping = mf.get_mapping(
        product_type="TYPE_A",
        processing_version="1.0.0",
    )

    assert expected_mapping == mf_mapping


@pytest.mark.unit
def test_get_mapping_explicit_all_versions_returns_requested_mapping(
    versioned_mappings_dir: Path,
) -> None:
    """When all selectors are provided, the exact mapping is returned."""
    expected_mapping_path = versioned_mappings_dir / "type_a_v2_map_v1.json"
    expected_mapping = load_json_file(expected_mapping_path)

    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)
    mf_mapping = mf.get_mapping(
        product_type="TYPE_A",
        processing_version="2.0.0",
        mapping_version="1.0.0",
    )

    assert expected_mapping == mf_mapping


@pytest.mark.unit
def test_get_mapping_explicit_product_type_checks_compatibility_when_product_path_is_given(
    versioned_mappings_dir: Path,
) -> None:
    """Explicit selection must still be compatible with product_path when product_path is provided."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MappingMissingError, match="No compatible mapping found"):
        mf.get_mapping(
            product_path="TYPEB_SAMPLE.SAFE",
            product_type="TYPE_A",
        )


@pytest.mark.unit
def test_get_mapping_missing_when_requested_mapping_version_does_not_exist(
    versioned_mappings_dir: Path,
) -> None:
    """A missing explicitly requested mapping version must raise MappingMissingError."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MappingMissingError):
        mf.get_mapping(
            product_type="TYPE_A",
            processing_version="2.0.0",
            mapping_version="9.9.9",
        )


@pytest.mark.unit
def test_get_mapping_missing_when_requested_processing_version_does_not_exist(
    versioned_mappings_dir: Path,
) -> None:
    """A missing explicitly requested product version must raise MappingMissingError."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MappingMissingError):
        mf.get_mapping(
            product_type="TYPE_A",
            processing_version="9.9.9",
        )


@pytest.mark.unit
def test_get_mapping_missing_when_no_mapping_matches_product_path(
    versioned_mappings_dir: Path,
) -> None:
    """Unknown product path must raise MappingMissingError."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MappingMissingError):
        mf.get_mapping(product_path="UNKNOWN_PRODUCT.SAFE")


@pytest.mark.unit
def test_get_mapping_missing_when_product_type_does_not_exist(
    versioned_mappings_dir: Path,
) -> None:
    """Unknown product type must raise MappingMissingError."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MappingMissingError):
        mf.get_mapping(product_type="TYPE_UNKNOWN")


@pytest.mark.unit
def test_get_mapping_missing_argument_when_no_product_path_and_no_product_type(
    versioned_mappings_dir: Path,
) -> None:
    """At least one of product_path or product_type must be provided."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    with pytest.raises(MissingArgumentError):
        mf.get_mapping()


@pytest.mark.unit
def test_get_mapping_applies_normalization_rules_when_pattern_file_does_not_contain_source_text(
    versioned_mappings_dir: Path,
    normalization_product_without_old_token: Path,
) -> None:
    """Normalization rules must replace text when the searched file does not contain the source token."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    mapping = mf.get_mapping(
        product_type="TYPE_A_NORMALIZED",
        processing_version="1.0.0",
        mapping_version="1.0.0",
        product_path=normalization_product_without_old_token,
    )

    assert mapping["selected_id"] == "TYPE_A_NORMALIZED__PV_1_0_0__MV_1_0_0"
    assert mapping["payload"]["token_value"] == "NEW_TOKEN"
    assert mapping["payload"]["nested"]["token_value"] == "NEW_TOKEN"


@pytest.mark.unit
def test_get_mapping_does_not_apply_normalization_rules_when_pattern_file_contains_source_text(
    versioned_mappings_dir: Path,
    normalization_product_with_old_token: Path,
) -> None:
    """Normalization rules must not replace text when the searched file already contains the source token."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    mapping = mf.get_mapping(
        product_type="TYPE_A_NORMALIZED",
        processing_version="1.0.0",
        mapping_version="1.0.0",
        product_path=normalization_product_with_old_token,
    )

    assert mapping["selected_id"] == "TYPE_A_NORMALIZED__PV_1_0_0__MV_1_0_0"
    assert mapping["payload"]["token_value"] == "OLD_TOKEN"
    assert mapping["payload"]["nested"]["token_value"] == "OLD_TOKEN"


@pytest.mark.unit
def test_get_mapping_from_product_path_applies_normalization_rules(
    versioned_mappings_dir: Path,
    normalization_product_without_old_token: Path,
) -> None:
    """Normalization must also be applied when mapping is selected from product_path compatibility."""
    mf = EOPFMappingFactory(mapping_path=versioned_mappings_dir)

    mapping = mf.get_mapping(product_path=normalization_product_without_old_token)

    assert mapping["product_type"] == "TYPE_A_NORMALIZED"
    assert mapping["payload"]["token_value"] == "NEW_TOKEN"
    assert mapping["payload"]["nested"]["token_value"] == "NEW_TOKEN"


@pytest.mark.unit
@pytest.mark.parametrize(
    "noise_file_content, expected_source_path",
    [
        (
            "<noiseVectorList><noiseVector><noiseLut>1 2</noiseLut></noiseVector></noiseVectorList>",
            "annotation/calibration/noise-test.xml:noiseVectorList/noiseVector#noiseLut",
        ),
        (
            "<noiseRangeVectorList><noiseRangeVector><noiseRangeLut>1 2</noiseRangeLut></noiseRangeVector></noiseRangeVectorList>",
            "annotation/calibration/noise-test.xml:noiseRangeVectorList/noiseRangeVector#noiseRangeLut",
        ),
    ],
)
def test_get_mapping_s01_noise_range_normalization_rule(
    tmp_path: Path,
    noise_file_content: str,
    expected_source_path: str,
) -> None:
    """S01 noise normalization must adapt mappings only when noiseRange tags are absent."""
    mapping_file = tmp_path / "s01_noise_normalized.json"
    product_dir = tmp_path / "S1A_EW_SLC__1SDV_TEST.SAFE"
    noise_file = product_dir / "annotation" / "calibration" / "noise-test.xml"
    noise_file.parent.mkdir(parents=True)
    noise_file.write_text(noise_file_content, encoding="utf-8")
    mapping_file.write_text(
        json.dumps(
            {
                "recognition": {
                    "filename_pattern": r"^S1._EW_SLC__1.*\.SAFE$",
                },
                "product_type": "S01SEWSLC_TEST",
                "processing_version": "1.0.0",
                "mapping_version": "1.0.0",
                "normalization_rules": [
                    {
                        "if_pattern_missing": {
                            "file_search": "annotation/calibration/noise*.xml",
                            "text_pattern": "</?noiseRange",
                        },
                        "replace_in_mapping": [
                            {
                                "from": "noiseRange",
                                "to": "noise",
                            },
                        ],
                    },
                ],
                "payload": {
                    "source_path": "annotation/calibration/noise-test.xml:noiseRangeVectorList/noiseRangeVector#noiseRangeLut",
                },
            },
        ),
        encoding="utf-8",
    )
    mf = EOPFMappingFactory(mapping_path=mapping_file)

    mapping = mf.get_mapping(
        product_path=product_dir,
        product_type="S01SEWSLC_TEST",
        processing_version="1.0.0",
        mapping_version="1.0.0",
    )

    assert mapping["payload"]["source_path"] == expected_source_path


@pytest.mark.unit
def test_get_mapping_explicit_product_type_filters_compatible_candidates_before_version_selection(
    overlapping_mappings_dir: Path,
) -> None:
    """
    When several mappings share the same product_type, processing_version and mapping_version,
    explicit selection with product_path must first filter on compatibility before selecting
    the mapping.

    This is a regression test for the case where the factory used to:
    1. filter by product_type
    2. select processing_version
    3. select mapping_version
    4. only then check compatibility

    which could fail even though a compatible mapping existed.
    """
    mf = EOPFMappingFactory(mapping_path=overlapping_mappings_dir)

    mapping = mf.get_mapping(
        product_type="TYPE_C",
        processing_version="1.0.0",
        mapping_version="1.0.0",
        product_path="TYPEC_SPECIAL_SAMPLE.SAFE",
    )

    assert mapping["selected_id"] == "TYPE_C_SPECIAL__PV_1_0_0__MV_1_0_0"
    assert mapping["product_type"] == "TYPE_C"
    assert mapping["processing_version"] == "1.0.0"
    assert mapping["mapping_version"] == "1.0.0"


@pytest.mark.unit
def test_get_mapping_explicit_product_type_keeps_generic_mapping_when_it_is_the_compatible_one(
    overlapping_mappings_dir: Path,
) -> None:
    """Explicit selection with product_path must return the generic compatible mapping when appropriate."""
    mf = EOPFMappingFactory(mapping_path=overlapping_mappings_dir)

    mapping = mf.get_mapping(
        product_type="TYPE_C",
        processing_version="1.0.0",
        mapping_version="1.0.0",
        product_path="TYPEC_GENERIC_SAMPLE.SAFE",
    )

    assert mapping["selected_id"] == "TYPE_C_GENERIC__PV_1_0_0__MV_1_0_0"
    assert mapping["product_type"] == "TYPE_C"
    assert mapping["processing_version"] == "1.0.0"
    assert mapping["mapping_version"] == "1.0.0"
