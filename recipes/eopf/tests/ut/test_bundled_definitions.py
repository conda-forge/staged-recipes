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
"""Validate bundled mapping and model definition files."""

import re
from pathlib import Path
from typing import Any

import pytest

from eopf.common.constants import EOPF_CPM_PATH
from eopf.common.file_utils import load_json_file
from eopf.common.functions_utils import validate_semver
from eopf.product.datatree_container_model import EOContainerModel
from eopf.product.datatree_product_model import EOProductModel
from eopf.product.model_factory import (
    EOPFModelFactory,
    MODEL_FILE_PATTERN,
    MODEL_VERSION_FLAG,
    PROCESSING_VERSION_FLAG as MODEL_PROCESSING_VERSION_FLAG,
    PRODUCT_TYPE_FLAG as MODEL_PRODUCT_TYPE_FLAG,
)

MODEL_DIR = EOPF_CPM_PATH / "product" / "models"
VERSIONED_DEFINITION_RE = re.compile(
    r"(?P<definition_name>.+)_pv(?P<processing_version>\d+\.\d+\.\d+)_mv"
    r"(?P<definition_version>\d+\.\d+\.\d+)\.json",
)


def _definition_paths(folder: Path, pattern: str) -> list[Path]:
    return sorted(folder.glob(pattern))


def _assert_versioned_filename_matches_content(
    path: Path,
    content: dict[str, Any],
    *,
    product_type_key: str,
    processing_version_key: str,
    definition_version_key: str,
) -> None:
    match = VERSIONED_DEFINITION_RE.fullmatch(path.name)
    assert match is not None, f"{path} does not follow '<name>_pv<semver>_mv<semver>.json'"

    product_type = content[product_type_key]
    assert match["definition_name"].startswith(product_type)
    assert match["processing_version"] == content[processing_version_key]
    assert match["definition_version"] == content[definition_version_key]


@pytest.mark.unit
def test_all_bundled_models_are_registered_by_factory() -> None:
    model_paths = set(_definition_paths(MODEL_DIR, MODEL_FILE_PATTERN))

    factory = EOPFModelFactory(model_path=MODEL_DIR)

    assert model_paths
    assert {model.path for model in factory.model_set} == model_paths


@pytest.mark.unit
@pytest.mark.parametrize("model_path", _definition_paths(MODEL_DIR, MODEL_FILE_PATTERN), ids=lambda path: path.name)
def test_bundled_model_file_is_well_formed(model_path: Path) -> None:
    content = load_json_file(model_path)

    assert isinstance(content, dict)
    for key in (MODEL_PRODUCT_TYPE_FLAG, MODEL_PROCESSING_VERSION_FLAG, MODEL_VERSION_FLAG):
        assert isinstance(content.get(key), str), f"{model_path} must define string field {key!r}"
    for key in (MODEL_PROCESSING_VERSION_FLAG, MODEL_VERSION_FLAG):
        validate_semver(content[key], key)

    _assert_versioned_filename_matches_content(
        model_path,
        content,
        product_type_key=MODEL_PRODUCT_TYPE_FLAG,
        processing_version_key=MODEL_PROCESSING_VERSION_FLAG,
        definition_version_key=MODEL_VERSION_FLAG,
    )

    if "variables" in content:
        assert isinstance(content.get("attrs"), dict), f"{model_path} must define model attrs"
        EOProductModel(**content)
    else:
        assert "sub_products" in content or "sub_containers" in content
        assert isinstance(content.get("attrs"), dict), f"{model_path} must define model attrs"
        EOContainerModel(**content)
