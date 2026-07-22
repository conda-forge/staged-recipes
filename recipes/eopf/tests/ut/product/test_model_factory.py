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

import pytest

from eopf.config.config import EOConfiguration
from eopf.exceptions.errors import ModelDefinitionError, ModelMissingError
from eopf.product.model_factory import EOPFModelFactory


class CustomProcessingVersionConvention:
    @staticmethod
    def validate_processing_version(value: str, field_name: str = "processing_version") -> None:
        if not value.startswith("PV-"):
            raise ValueError(f"{field_name} must start with PV-")

    @staticmethod
    def processing_version_key(value: str) -> int:
        return int(value.removeprefix("PV-"))


# ---------------------------------------------------------------------
# HELPERS
# ---------------------------------------------------------------------
def _write_json(path: Path, content: dict) -> None:
    """Write JSON content to a file."""
    path.write_text(json.dumps(content), encoding="utf-8")


# ---------------------------------------------------------------------
# FIXTURES
# ---------------------------------------------------------------------
@pytest.fixture
def model_dir(tmp_path: Path) -> Path:
    """Create the main model directory."""
    model_dir = tmp_path / "models"
    model_dir.mkdir()
    return model_dir


@pytest.fixture
def alt_model_dir(tmp_path: Path) -> Path:
    """Create the alternative model directory."""
    alt_model_dir = tmp_path / "alt_models"
    alt_model_dir.mkdir()
    return alt_model_dir


@pytest.fixture
def configured_model_folders(model_dir: Path, alt_model_dir: Path):
    """
    Configure EOConfiguration model folders for the duration of a test.

    The previous values are restored after the test finishes.
    """
    config = EOConfiguration()

    had_model_folder = config.has_value("model__folder")
    old_model_folder = config.get("model__folder") if had_model_folder else None

    had_alt_model_folder = config.has_value("model__alt_folder")
    old_alt_model_folder = config.get("model__alt_folder") if had_alt_model_folder else None

    config["model__folder"] = str(model_dir)
    config["model__alt_folder"] = str(alt_model_dir)

    try:
        yield
    finally:
        if had_model_folder:
            config["model__folder"] = old_model_folder
        else:
            del config["model__folder"]

        if had_alt_model_folder:
            config["model__alt_folder"] = old_alt_model_folder
        elif config.has_value("model__alt_folder"):
            del config["model__alt_folder"]


# ---------------------------------------------------------------------
# REGISTRATION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_register_single_model_file(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.0.0.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
            "title": "test",
        },
    )

    factory = EOPFModelFactory(model_dir)

    assert len(factory.model_set) == 1

    model = next(iter(factory.model_set))
    assert model.path == model_file
    assert model.product_type == "S01SEWRAW"
    assert model.processing_version == "1.0.0"
    assert model.model_version == "1.0.0"


@pytest.mark.unit
def test_register_directory_with_multiple_models(model_dir: Path):
    _write_json(
        model_dir / "S01SEWRAW_pv1.0.0_mv1.0.0.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        model_dir / "S01SEWRAW_pv1.0.0_mv1.1.0.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.1.0",
        },
    )
    _write_json(
        model_dir / "S01SEWRAW_pv2.0.0_mv1.0.0.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "2.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    assert len(factory.model_set) == 3


@pytest.mark.unit
def test_register_file_missing_product_type_raises(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.0.0.json"
    _write_json(
        model_file,
        {
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    with pytest.raises(ModelDefinitionError, match="product_type"):
        EOPFModelFactory(model_dir)


@pytest.mark.unit
def test_register_file_missing_processing_version_raises(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.0.0.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "model_version": "1.0.0",
        },
    )

    with pytest.raises(ModelDefinitionError, match="processing_version"):
        EOPFModelFactory(model_dir)


@pytest.mark.unit
def test_register_file_missing_model_version_raises(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.0.0.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
        },
    )

    with pytest.raises(ModelDefinitionError, match="model_version"):
        EOPFModelFactory(model_dir)


@pytest.mark.unit
def test_register_duplicate_model_raises(model_dir: Path):
    _write_json(
        model_dir / "model_a.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        model_dir / "model_b.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    with pytest.raises(ModelDefinitionError, match="Duplicate model registration"):
        EOPFModelFactory(model_dir)


@pytest.mark.unit
def test_register_invalid_processing_version_raises(model_dir: Path):
    _write_json(
        model_dir / "model.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0",
            "model_version": "1.0.0",
        },
    )

    with pytest.raises(Exception, match="processing_version"):
        EOPFModelFactory(model_dir)


@pytest.mark.unit
def test_register_processing_version_uses_product_convention(monkeypatch, model_dir: Path):
    monkeypatch.setattr(
        "eopf.product.model_factory.get_product_convention",
        lambda: CustomProcessingVersionConvention,
    )
    model_v1 = model_dir / "m1.json"
    model_v2 = model_dir / "m2.json"
    _write_json(
        model_v1,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "PV-1",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        model_v2,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "PV-2",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    assert factory.get_model_path("S01SEWRAW") == model_v2


@pytest.mark.unit
def test_register_invalid_model_version_raises(model_dir: Path):
    _write_json(
        model_dir / "model.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0",
        },
    )

    with pytest.raises(Exception, match="model_version"):
        EOPFModelFactory(model_dir)


# ---------------------------------------------------------------------
# SELECTION BY PRODUCT TYPE / VERSION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_get_model_path_exact_match(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.2.0.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.2.0",
            "foo": "bar",
        },
    )

    factory = EOPFModelFactory(model_dir)

    selected = factory.get_model_path(
        product_type="S01SEWRAW",
        processing_version="1.0.0",
        model_version="1.2.0",
    )

    assert selected == model_file


@pytest.mark.unit
def test_get_model_content_exact_match(model_dir: Path):
    model_file = model_dir / "S01SEWRAW_pv1.0.0_mv1.2.0.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.2.0",
            "foo": "bar",
        },
    )

    factory = EOPFModelFactory(model_dir)

    content = factory.get_model_content(
        product_type="S01SEWRAW",
        processing_version="1.0.0",
        model_version="1.2.0",
    )

    assert content["product_type"] == "S01SEWRAW"
    assert content["processing_version"] == "1.0.0"
    assert content["model_version"] == "1.2.0"
    assert content["foo"] == "bar"


@pytest.mark.unit
def test_get_model_latest_model_version_when_not_provided(model_dir: Path):
    model_v1 = model_dir / "m1.json"
    model_v2 = model_dir / "m2.json"

    _write_json(
        model_v1,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        model_v2,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.2.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    selected = factory.get_model_path(
        product_type="S01SEWRAW",
        processing_version="1.0.0",
    )

    assert selected == model_v2


@pytest.mark.unit
def test_get_model_latest_processing_version_when_not_provided(model_dir: Path):
    model_v1 = model_dir / "m1.json"
    model_v2 = model_dir / "m2.json"

    _write_json(
        model_v1,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "9.9.9",
        },
    )
    _write_json(
        model_v2,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "2.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    selected = factory.get_model_path(product_type="S01SEWRAW")

    assert selected == model_v2


@pytest.mark.unit
def test_get_model_latest_processing_version_then_latest_model_version(model_dir: Path):
    old_prod_high_model = model_dir / "old_prod_high_model.json"
    new_prod_low_model = model_dir / "new_prod_low_model.json"
    new_prod_high_model = model_dir / "new_prod_high_model.json"

    _write_json(
        old_prod_high_model,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "9.9.9",
        },
    )
    _write_json(
        new_prod_low_model,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "2.0.0",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        new_prod_high_model,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "2.0.0",
            "model_version": "1.2.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    selected = factory.get_model_path(product_type="S01SEWRAW")

    assert selected == new_prod_high_model


# ---------------------------------------------------------------------
# MISSING SELECTION CASES
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_get_model_unknown_product_type_raises(model_dir: Path):
    _write_json(
        model_dir / "model.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    with pytest.raises(ModelMissingError, match="product_type=S01SIWRAW"):
        factory.get_model_path(product_type="S01SIWRAW")


@pytest.mark.unit
def test_get_model_unknown_processing_version_raises(model_dir: Path):
    _write_json(
        model_dir / "model.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    with pytest.raises(ModelMissingError, match="processing_version=2.0.0"):
        factory.get_model_path(
            product_type="S01SEWRAW",
            processing_version="2.0.0",
        )


@pytest.mark.unit
def test_get_model_unknown_model_version_raises(model_dir: Path):
    _write_json(
        model_dir / "model.json",
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory(model_dir)

    with pytest.raises(ModelMissingError, match="model_version=2.0.0"):
        factory.get_model_path(
            product_type="S01SEWRAW",
            processing_version="1.0.0",
            model_version="2.0.0",
        )


# ---------------------------------------------------------------------
# DEFAULT CONFIGURED PATHS
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_default_constructor_uses_model_folder(
    model_dir: Path,
    configured_model_folders,
):
    model_file = model_dir / "main_model.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory()

    selected = factory.get_model_path("S01SEWRAW")
    assert selected == model_file


@pytest.mark.unit
def test_default_constructor_uses_alt_folder_when_main_empty(
    alt_model_dir: Path,
    configured_model_folders,
):
    model_file = alt_model_dir / "alt_model.json"
    _write_json(
        model_file,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory()

    selected = factory.get_model_path("S01SEWRAW")
    assert selected == model_file


@pytest.mark.unit
def test_default_constructor_prefers_highest_version_across_main_and_alt(
    model_dir: Path,
    alt_model_dir: Path,
    configured_model_folders,
):
    main_model = model_dir / "main_model.json"
    alt_model = alt_model_dir / "alt_model.json"

    _write_json(
        main_model,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "1.0.0",
            "model_version": "1.0.0",
        },
    )
    _write_json(
        alt_model,
        {
            "product_type": "S01SEWRAW",
            "processing_version": "2.0.0",
            "model_version": "1.0.0",
        },
    )

    factory = EOPFModelFactory()

    selected = factory.get_model_path("S01SEWRAW")
    assert selected == alt_model
