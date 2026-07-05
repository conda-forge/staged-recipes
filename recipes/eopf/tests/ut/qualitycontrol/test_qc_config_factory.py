import os.path

import pytest

from eopf.exceptions.errors import (
    EOQCConfigMalformed,
    EOQCConfigMissing,
    EOQCInspectionMalformed,
    EOQCInspectionMissing,
)
from eopf.qualitycontrol import EOQCConfig, EOQCConfigRepository
from eopf.qualitycontrol.impl.eo_qc_impl import EOQCFormula


@pytest.mark.unit
def test_eoqc_config_init():
    qc_config = EOQCConfig(
        version="1.0.0",
        identifier="truc",
        inspection_map={},
        product_type="S2MSI",
        processing_version="1.0.0",
    )
    assert qc_config
    assert qc_config.identifier == "truc"
    assert qc_config.product_type == "S2MSI"
    assert qc_config.processing_version == "1.0.0"
    assert qc_config.version == "1.0.0"
    assert qc_config.inspection_map == {}


@pytest.fixture
def eoqcConfigFactory():
    return EOQCConfigRepository()


@pytest.mark.unit
@pytest.mark.parametrize("product_type, processing_version", [("FAKEONE", "1.1.0")])
def test_eoqcConfigFactory_get_qc_configs(product_type, processing_version, EMBEDED_TEST_DATA_FOLDER_UNIT):
    qc_configFactory = EOQCConfigRepository(
        config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
    )
    config = qc_configFactory.get_config(product_type, processing_version=processing_version)
    assert config.product_type == product_type
    assert config.processing_version == processing_version
    assert config.identifier == "FAKEY"


@pytest.mark.unit
def test_eoqcConfigFactory_get_qc_configs_not_available(eoqcConfigFactory):
    with pytest.raises(EOQCConfigMissing):
        eoqcConfigFactory.get_config("DOESNTEXISTS", "1.0.0")


@pytest.mark.unit
def test_eoqcConfigFactory_add_config_folder(eoqcConfigFactory, EMBEDED_TEST_DATA_FOLDER_UNIT):
    eoqcConfigFactory.register_config_folder(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol"))
    config = eoqcConfigFactory.get_config("FAKEONE", "1.1.0")
    assert config.identifier == "FAKEY"
    assert len(config.inspection_map) == 3


@pytest.mark.unit
def test_eoqcConfigFactory_direct_config_load(eoqcConfigFactory, EMBEDED_TEST_DATA_FOLDER_UNIT):
    eoqcConfigFactory.register_config_folder(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol"))
    config = eoqcConfigFactory.load_config_file(
        os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol", "FAKEONE_checklist.json"),
    )
    assert config.identifier == "FAKEY"
    assert len(config.inspection_map) == 3


@pytest.mark.unit
def test_eoqcConfigFactory_direct_config_load_with_replaced(eoqcConfigFactory, EMBEDED_TEST_DATA_FOLDER_UNIT):
    eoqcConfigFactory.register_config_folder(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol"))
    config = eoqcConfigFactory.load_config_file(
        os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol", "FAKEONEREPL_checklist.json"),
        parameters={"V_MIN": 0},
    )
    assert config.identifier == "FAKEYREPL"
    assert len(config.inspection_map) == 1
    assert config.inspection_map["fake_inspection_repl"].evaluator.parameters[0]["value"] == 0
    assert isinstance(config.inspection_map["fake_inspection_repl"], EOQCFormula)


@pytest.mark.unit
def test_eoqcConfigFactory_direct_config_load_with_replaced_error(eoqcConfigFactory, EMBEDED_TEST_DATA_FOLDER_UNIT):
    eoqcConfigFactory.register_config_folder(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol"))
    with pytest.raises(KeyError, match="Missing replacement parameter"):
        eoqcConfigFactory.load_config_file(
            os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol", "FAKEONEREPL_checklist.json"),
            parameters={},
        )


# ---------------------------------------------------------------------
# SEMVER VALIDATION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_get_config_rejects_invalid_processing_version(eoqcConfigFactory):
    with pytest.raises(ValueError, match="processing_version"):
        eoqcConfigFactory.get_config("FAKEONE", "01.0.0")


@pytest.mark.unit
def test_load_config_file_rejects_invalid_checklist_version(tmp_path):
    inspection_file = tmp_path / "fake_inspections.json"
    inspection_file.write_text(
        """
        {
          "quality_inspections": [
            {
              "identifier": "fake_inspection",
              "version": "1.0.0",
              "type": "formula",
              "name": "n",
              "description": "d",
              "expression": "1 == 1",
              "evaluator": {"type": "python", "parameters": []}
            }
          ]
        }
        """,
        encoding="utf-8",
    )

    config_file = tmp_path / "fake_checklist.json"
    config_file.write_text(
        """
        {
          "identifier": "FAKE",
          "product_type": "FAKEONE",
          "processing_version": "1.0.0",
          "version": "01.0.0",
          "inspection_list": {"fake_inspection": "1.0.0"}
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(ValueError, match="version"):
        repo.load_config_file(config_file)


@pytest.mark.unit
def test_load_inspection_definition_rejects_invalid_requested_semver(eoqcConfigFactory):
    with pytest.raises(ValueError, match="inspection_version"):
        eoqcConfigFactory._load_inspection_definition("fake", "01.0.0")


# ---------------------------------------------------------------------
# CHECKLIST SELECTION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_selects_highest_checklist_semver(tmp_path):
    inspection_file = tmp_path / "fake_inspections.json"
    inspection_file.write_text(
        """
        {
          "quality_inspections": [
            {
              "identifier": "fake_inspection",
              "version": "1.0.0",
              "type": "formulas",
              "thematic": "GENERAL_QUALITY",
              "description": "validate that orbit number is between value",
              "precondition": {},
              "evaluator": {
                "parameters": [
                {
                    "name": "v_min",
                    "value": "0"
                },
                {
                    "name": "v_max",
                    "value": 9999999
                }
                ],
                "variables": [],
                "attributes": [
                {
                    "name": "absolute_orbit",
                    "path": "other_metadata/absolute_orbit_number"
                }
                ],
                "formula": "v_min < absolute_orbit < v_max"
                }
                }
          ]
        }
        """,
        encoding="utf-8",
    )

    config_file_v1 = tmp_path / "fake_v1.json"
    config_file_v1.write_text(
        """
        {
          "identifier": "CFG_1",
          "product_type": "FAKEONE",
          "processing_version": "1.1.0",
          "version": "1.0.0",
          "inspection_list": {"fake_inspection": "1.0.0"}
        }
        """,
        encoding="utf-8",
    )

    config_file_v2 = tmp_path / "fake_v2.json"
    config_file_v2.write_text(
        """
        {
          "identifier": "CFG_2",
          "product_type": "FAKEONE",
          "processing_version": "1.1.0",
          "version": "1.2.0",
          "inspection_list": {"fake_inspection": "1.0.0"}
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    config = repo.get_config("FAKEONE", "1.1.0")
    assert config.identifier == "CFG_2"
    assert config.version == "1.2.0"


# ---------------------------------------------------------------------
# CACHE BEHAVIOR
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_get_config_uses_cache_for_same_processing_version(EMBEDED_TEST_DATA_FOLDER_UNIT):
    repo = EOQCConfigRepository(
        config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
    )

    config1 = repo.get_config("FAKEONE", "1.1.0")
    config2 = repo.get_config("FAKEONE", "1.1.0")

    assert config1 is config2


# ---------------------------------------------------------------------
# MALFORMED CHECKLISTS
# ---------------------------------------------------------------------
@pytest.mark.unit
@pytest.mark.parametrize(
    "payload, expected_message",
    [
        ({}, "No identifier found"),
        ({"identifier": "X"}, "No Product type info"),
        ({"identifier": "X", "product_type": "FAKE"}, "No Processing version info"),
        (
            {"identifier": "X", "product_type": "FAKE", "processing_version": "1.0.0"},
            "No Version info",
        ),
        (
            {
                "identifier": "X",
                "product_type": "FAKE",
                "processing_version": "1.0.0",
                "version": "1.0.0",
            },
            "No inspection_list found",
        ),
    ],
)
def test_load_config_file_missing_required_fields(tmp_path, payload, expected_message):
    config_file = tmp_path / "broken_checklist.json"
    import json

    config_file.write_text(json.dumps(payload), encoding="utf-8")

    repo = EOQCConfigRepository(config_folders=[])
    with pytest.raises(EOQCConfigMalformed, match=expected_message):
        repo.load_config_file(config_file)


# ---------------------------------------------------------------------
# MALFORMED / MISSING INSPECTIONS
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_load_inspection_definition_missing_quality_inspections(tmp_path):
    inspection_file = tmp_path / "broken_inspections.json"
    inspection_file.write_text("{}", encoding="utf-8")

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(EOQCInspectionMalformed, match="No quality_inspection list"):
        repo._load_inspection_definition("fake", "1.0.0")


@pytest.mark.unit
def test_load_inspection_definition_missing_identifier(tmp_path):
    inspection_file = tmp_path / "broken_inspections.json"
    inspection_file.write_text(
        """
        {
          "quality_inspections": [
            {"version": "1.0.0", "type": "formula"}
          ]
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(EOQCInspectionMalformed, match="No identifier found"):
        repo._load_inspection_definition("fake", "1.0.0")


@pytest.mark.unit
def test_load_inspection_definition_missing_version(tmp_path):
    inspection_file = tmp_path / "broken_inspections.json"
    inspection_file.write_text(
        """
        {
          "quality_inspections": [
            {"identifier": "fake", "type": "formula"}
          ]
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(EOQCInspectionMalformed, match="No version found"):
        repo._load_inspection_definition("fake", "1.0.0")


@pytest.mark.unit
def test_load_inspection_definition_invalid_version_in_file(tmp_path):
    inspection_file = tmp_path / "broken_inspections.json"
    inspection_file.write_text(
        """
        {
          "quality_inspections": [
            {"identifier": "fake", "version": "01.0.0", "type": "formula"}
          ]
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(EOQCInspectionMalformed, match="Invalid inspection version semver"):
        repo._load_inspection_definition("fake", "1.0.0")


@pytest.mark.unit
def test_build_config_raises_when_inspection_reference_missing(tmp_path):
    config_file = tmp_path / "fake_checklist.json"
    config_file.write_text(
        """
        {
          "identifier": "FAKE",
          "product_type": "FAKEONE",
          "processing_version": "1.0.0",
          "version": "1.0.0",
          "inspection_list": {"missing_inspection": "1.0.0"}
        }
        """,
        encoding="utf-8",
    )

    repo = EOQCConfigRepository(config_folders=[tmp_path])
    with pytest.raises(EOQCInspectionMissing):
        repo.load_config_file(config_file)


# ---------------------------------------------------------------------
# PLACEHOLDER HELPERS
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_contains_placeholder_true():
    data = {"a": [1, {"b": "@@@V_MIN@@@"}]}
    assert EOQCConfigRepository._contains_placeholder(data) is True


@pytest.mark.unit
def test_contains_placeholder_false():
    data = {"a": [1, {"b": "plain_value"}]}
    assert EOQCConfigRepository._contains_placeholder(data) is False


@pytest.mark.unit
def test_resolve_placeholders_replaces_exact_tokens_only():
    data = {
        "a": "@@@FOO@@@",
        "b": "prefix_@@@FOO@@@",
        "c": ["@@@BAR@@@", 1],
    }

    resolved = EOQCConfigRepository._resolve_placeholders(
        data,
        parameters={"FOO": 42, "BAR": "x"},
    )

    assert resolved["a"] == 42
    assert resolved["b"] == "prefix_@@@FOO@@@"
    assert resolved["c"][0] == "x"
    assert resolved["c"][1] == 1


@pytest.mark.unit
def test_resolve_placeholders_raises_on_missing_key():
    data = {"a": "@@@MISSING@@@"}

    with pytest.raises(KeyError):
        EOQCConfigRepository._resolve_placeholders(data, parameters={})
