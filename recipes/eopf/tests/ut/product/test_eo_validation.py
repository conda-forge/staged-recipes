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
from unittest.mock import Mock

import pytest
from xarray import DataTree

from eopf.product.datatree_validation import (
    AttributeModel,
    ValidationMode,
    _has_oblivion_ancestors,
    append_to_anomalies,
    check_attributes_top_category,
    validate_attrs_against_model,
)
from eopf.product.structure_convention_protocol import StacProductStructureConventionMixin


class NoMandatoryAttrCategoryConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_attr_category(cls):
        return None

    @classmethod
    def get_optional_attr_category(cls):
        return None


class EmptyMandatoryAttrCategoryConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_attr_category(cls):
        return ()

    @classmethod
    def get_optional_attr_category(cls):
        return None


class EmptyAttrCategoryConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_attr_category(cls):
        return ()

    @classmethod
    def get_optional_attr_category(cls):
        return ()


@pytest.mark.unit
@pytest.mark.parametrize(
    "validation_mode, list_mode",
    [
        (
            ValidationMode.METADATA | ValidationMode.STRUCTURE,
            [ValidationMode.METADATA, ValidationMode.STRUCTURE],
        ),
        (
            ValidationMode.METADATA | ValidationMode.STRUCTURE | ValidationMode.MODEL,
            [ValidationMode.METADATA, ValidationMode.STRUCTURE, ValidationMode.MODEL],
        ),
        (
            ValidationMode.FULL,
            [ValidationMode.METADATA, ValidationMode.STRUCTURE, ValidationMode.MODEL],
        ),
        (ValidationMode.NONE, [ValidationMode.NONE]),
    ],
)
def test_validation_mode_flags(validation_mode, list_mode):
    for p in list_mode:
        assert p in validation_mode


@pytest.mark.unit
@pytest.mark.parametrize(
    "validation_mode, list_mode",
    [
        (ValidationMode.METADATA, [ValidationMode.METADATA, ValidationMode.STRUCTURE]),
        (
            ValidationMode.METADATA | ValidationMode.MODEL,
            [ValidationMode.METADATA, ValidationMode.STRUCTURE, ValidationMode.MODEL],
        ),
    ],
)
def test_validation_mode_flags_error(validation_mode, list_mode):
    with pytest.raises(AssertionError):
        for p in list_mode:
            assert p in validation_mode


##########################################
# append_to_anomalies
##########################################


@pytest.mark.unit
def test_append_to_anomalies_adds_entry_and_logs():
    anomalies = []
    logger = Mock()

    append_to_anomalies(anomalies, "MODEL", "Something wrong", logger)

    assert len(anomalies) == 1
    assert anomalies[0].category == "MODEL"
    assert anomalies[0].description == "Something wrong"
    logger.debug.assert_called_once()


##########################################
# validate_attrs_against_model
##########################################


@pytest.mark.unit
def test_validate_attrs_against_model_missing_required():
    dt = DataTree()
    dt.attrs = {"present": 1}
    constraints = {"missing": AttributeModel(required=True)}

    anomalies = []

    validate_attrs_against_model(dt, constraints, "AT_LEAST", anomalies, None)

    assert len(anomalies) == 1
    assert "missing" in anomalies[0].description


@pytest.mark.unit
def test_validate_attrs_exact_reports_extra_attribute():
    dt = DataTree()
    dt.attrs.update({"a": 1, "extra": 2})
    constraints = {"a": AttributeModel(required=True)}

    anomalies = []

    validate_attrs_against_model(dt, constraints, "EXACT", anomalies, None)

    assert any("extra" in a.description for a in anomalies)


@pytest.mark.unit
def test_validate_attrs_dont_look_under():
    dt = DataTree()
    dt.attrs.update({"parent": {"child": 1}})
    constraints = {"parent": AttributeModel(required=True, dont_look_under=True)}

    anomalies = []

    validate_attrs_against_model(dt, constraints, "EXACT", anomalies, None)

    # The child attribute should NOT trigger anomalies
    assert len(anomalies) == 0


##########################################
# _has_oblivion_ancestors
##########################################


@pytest.mark.unit
def test_has_oblivion_ancestors_true():
    constraints = {"a": AttributeModel(dont_look_under=True)}
    assert _has_oblivion_ancestors("a/b/c", constraints) is True


@pytest.mark.unit
def test_has_oblivion_ancestors_false():
    constraints = {"x": AttributeModel(dont_look_under=True)}
    assert _has_oblivion_ancestors("a/b", constraints) is False


##########################################
# Top-level attribute categories
##########################################


@pytest.mark.unit
def test_check_attributes_top_category_missing():
    anomalies = []
    product = DataTree()
    product.attrs.update({"only_one": 1})

    check_attributes_top_category(product, anomalies, None)

    assert len(anomalies) >= 1
    for key in StacProductStructureConventionMixin.get_mandatory_attr_category():
        assert key in anomalies[0].description


@pytest.mark.unit
def test_check_attributes_top_category_none_skips_validation(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.product_convention_provider.get_product_convention",
        lambda: NoMandatoryAttrCategoryConvention,
    )
    anomalies = []
    product = DataTree()

    check_attributes_top_category(product, anomalies, None)

    assert anomalies == []


@pytest.mark.unit
def test_check_attributes_top_category_empty_allows_no_mandatory_categories(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.product_convention_provider.get_product_convention",
        lambda: EmptyMandatoryAttrCategoryConvention,
    )
    anomalies = []
    product = DataTree()

    check_attributes_top_category(product, anomalies, None)

    assert anomalies == []


@pytest.mark.unit
def test_check_attributes_top_category_empty_allows_no_extra_categories(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.product_convention_provider.get_product_convention",
        lambda: EmptyAttrCategoryConvention,
    )
    anomalies = []
    product = DataTree()
    product.attrs["extra"] = 1

    check_attributes_top_category(product, anomalies, None)

    assert len(anomalies) == 1
    assert "Found invalid top-level attribute categories" in anomalies[0].description
