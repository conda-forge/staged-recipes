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
import logging
from pathlib import Path

import numpy as np
import pytest
import xarray as xr
from xarray import DataTree

from eopf.common.constants import EOPRODUCT_CATEGORY
from eopf.common.file_utils import AnyPath, load_json_file
from eopf.product.datatree_product_model import EOProductModel, EOVariableModel, model_to_product, product_to_model
from eopf.product.datatree_product_validation import (
    check_coherent_dimension_product,
    check_eoproduct_groups,
    check_variable_attributes,
    validate_product_against_model,
)
from eopf.product.datatree_validation import AttributeModel, ValidationMode
from eopf.product.product_stac_convention import StacProductConvention
from eopf.product.structure_convention_protocol import StacProductStructureConventionMixin


class NoGroupValidationConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_groups(cls):
        return None

    @classmethod
    def get_optional_groups(cls):
        return None


class EmptyGroupValidationConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_groups(cls):
        return ()

    @classmethod
    def get_optional_groups(cls):
        return ()


class NoVariableAttributeValidationConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_variable_atts(cls):
        return None

    @classmethod
    def get_optional_variable_attrs(cls):
        return None


class GenericModelConvention(NoVariableAttributeValidationConvention):
    pass


class EmptyVariableAttributeValidationConvention(StacProductStructureConventionMixin):
    @classmethod
    def get_mandatory_variable_atts(cls):
        return ()

    @classmethod
    def get_optional_variable_attrs(cls):
        return ()


class MissingStructureProtocolConvention:
    pass


class CustomProcessingVersionConvention:
    @staticmethod
    def validate_processing_version(value: str, field_name: str = "processing_version") -> None:
        if not value.startswith("PV-"):
            raise ValueError(f"{field_name} must start with PV-")


@pytest.fixture
def product() -> DataTree:
    product = DataTree(name="product_name")

    for group in StacProductStructureConventionMixin.MANDATORY_GROUPS:
        product[group] = DataTree(name=group)
        product[f"{group}/image"] = DataTree(name="image")
        product[f"{group}/image/b01"] = xr.DataArray(
            np.random.randint(0, 100, size=(50, 50)),
            name="b01",
        )
        product[f"{group}/image/b01"].attrs["long_name"] = "truc"
        product[f"{group}/image/b01"].attrs["short_name"] = "truc"
        product[f"{group}/image/b01"].attrs["dtype"] = "truc"
        product[f"{group}/image/b01"].attrs["standard_name"] = "truc"
    product.attrs["stac_discovery"] = {}
    product.attrs["other_metadata"] = {"truc": 1.0}
    product.cpm.product_kind = EOPRODUCT_CATEGORY
    #    assert product.is_valid()
    product.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/product/v0.1.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                    [50.28376, -13.843143],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "bbox": [50.69191, -13.843143, 47.965759, -11.565237],
        "properties": {
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.459284Z",
            "end_datetime": "2022-06-14T13:03:43.459284Z",
            "created": "2022-06-14T13:57:37Z",
            "platform": "sentinel-3A",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "mission": "copernicus",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "Earth Observation",
            "eopf:datatake_id": "350542",
            "product:type": "S3SLSLST",
            "product:timeliness": "PT1H30M",
            "processing:version": "1.0.1",
            "processing:datetime": "2022-06-14T13:57:37Z",
            "processing:facility": "ESA S3MPC",
            "processing:software": {"Sentinel-1 IPF": "002.71"},
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }
    return product


@pytest.fixture
def invalid_product() -> DataTree:
    product = DataTree(name="product_name")

    for group in StacProductStructureConventionMixin.MANDATORY_GROUPS:
        product[group] = DataTree(name=group)
        product[f"{group}/image"] = DataTree(name="image")
        product[f"{group}/image/b01"] = xr.DataArray(
            np.random.randint(0, 100, size=(50, 50)),
            name="b01",
        )
        product[f"{group}/image/b01"].attrs["short_name"] = "truc"
        product[f"{group}/image/b01"].attrs["dtype"] = "truc"
        product[f"{group}/image/b02"] = xr.DataArray(
            np.random.randint(0, 100, size=(50, 50)),
            name="b02",
        )
        product[group]["image/b02"].attrs["short_name"] = "truc"
        product[group]["image/b02"].attrs["standard_name"] = "unknown"
        product[group]["image/b02"].attrs["dtype"] = "truc"
        product[group]["image/b02"].attrs["truc"] = "truc"

        # --- Empty group variable ---
        empty = xr.DataArray(
            np.ones((10, 10)) * 2048,
            name="empty",
        )
        empty.attrs.update(
            {
                "long_name": "truc",
                "short_name": "truc",
                "dtype": "truc",
            },
        )
        product[f"{group}/empty_group"] = DataTree(name="empty_group")
        product[f"{group}/empty_group/empty"] = empty

    product.attrs["stac_discovery"] = {}
    product.attrs["other_metadata"] = {"truc": 1.0}

    #    assert product.is_valid()
    product.attrs["stac_discovery"] = {
        "type": "Feature",
        "stac_version": "1.1.0",
        "stac_extensions": [
            "https://cs-si.github.io/eopf-stac-extension/v1.2.0/schema.json",
            "https://stac-extensions.github.io/sat/v1.0.0/schema.json",
            "https://stac-extensions.github.io/processing/v1.2.0/schema.json",
        ],
        "id": "S3A_SL_2_LST____20220614T130003_20220614T130503_20220614T135543_0299_086_238",
        "geometry": {
            "coordinates": [
                [
                    [50.28376, -13.843143],
                    [47.965759, -13.308908],
                    [48.387905, -11.565237],
                    [50.69191, -12.0927],
                ],
            ],
            "type": "Polygon",
        },
        "gsd": "1000",
        "properties": {
            "datetime": None,
            "start_datetime": "2022-06-14T13:00:43.459284Z",
            "end_datetime": "2022-06-14T13:03:43.459284Z",
            "created": "2022-06-14T13:57:37Z",
            "platform": "sentinel-3A",
            "instruments": ["slstr"],
            "constellation": "sentinel-3",
            "mission": "copernicus",
            "sat:anx_datetime": "2022-06-14T12:40:20.457854",
            "sat:absolute_orbit": 32936,
            "sat:relative_orbit": 238,
            "sat:orbit_state": "ascending",
            "sat:platform_international_designator": "2016-011A",
            "eopf:instrument_mode": "Earth Observation",
            "eopf:datatake_id": "350542",
            "product:type": "S3SLSLST",
            "processing:version": ["truc"],
            "processing:level": "L2",
            "providers": [
                {"name": "S3MPC", "roles": ["processor"]},
                {"name": "ACRI-ST", "roles": ["producer"]},
            ],
        },
        "links": [
            {"rel": "self", "href": "./.zattrs.json", "type": "application/json"},
        ],
        "assets": {},
    }
    return product


@pytest.fixture
def product_model() -> EOProductModel:
    return EOProductModel(
        product_type="S3SLSLST",
        attrs={
            "stac_discovery/type": AttributeModel(),
            "stac_discovery/stac_version": AttributeModel(),
            "stac_discovery/stac_extensions": AttributeModel(),
            "stac_discovery/id": AttributeModel(),
            "stac_discovery/geometry/coordinates": AttributeModel(),
            "stac_discovery/geometry/type": AttributeModel(),
            "stac_discovery/gsd": AttributeModel(),
            "stac_discovery/bbox": AttributeModel(),
            "stac_discovery/properties/datetime": AttributeModel(),
            "stac_discovery/properties/start_datetime": AttributeModel(),
            "stac_discovery/properties/end_datetime": AttributeModel(),
            "stac_discovery/properties/created": AttributeModel(),
            "stac_discovery/properties/platform": AttributeModel(),
            "stac_discovery/properties/instruments": AttributeModel(),
            "stac_discovery/properties/constellation": AttributeModel(),
            "stac_discovery/properties/mission": AttributeModel(),
            "stac_discovery/properties/sat:anx_datetime": AttributeModel(),
            "stac_discovery/properties/sat:absolute_orbit": AttributeModel(),
            "stac_discovery/properties/sat:relative_orbit": AttributeModel(),
            "stac_discovery/properties/sat:orbit_state": AttributeModel(),
            "stac_discovery/properties/sat:platform_international_designator": AttributeModel(),
            "stac_discovery/properties/eopf:instrument_mode": AttributeModel(),
            "stac_discovery/properties/eopf:datatake_id": AttributeModel(),
            "stac_discovery/properties/product:type": AttributeModel(),
            "stac_discovery/properties/product:timeliness": AttributeModel(),
            "stac_discovery/properties/processing:version": AttributeModel(),
            "stac_discovery/properties/processing:datetime": AttributeModel(),
            "stac_discovery/properties/processing:facility": AttributeModel(),
            "stac_discovery/properties/processing:level": AttributeModel(),
            "stac_discovery/properties/providers": AttributeModel(),
            "stac_discovery/links": AttributeModel(),
            "stac_discovery/assets": AttributeModel(dont_look_under=True),
            "other_metadata/truc": AttributeModel(),
            "other_metadata/eopf_category": AttributeModel(
                value_regex="eocontainer|eoproduct",
            ),
            "processing_history": AttributeModel(required=False, dont_look_under=True),
            "stac_discovery/properties/processing:software": AttributeModel(
                required=False,
                dont_look_under=True,
            ),
        },
        variables={
            "/measurements/image/b01": EOVariableModel(
                dtype="int64",
                dims=["dim_0", "dim_1"],
                attrs={
                    "long_name": AttributeModel(),
                    "short_name": AttributeModel(),
                    "dtype": AttributeModel(),
                    "standard_name": AttributeModel(),
                },
            ),
        },
    )


@pytest.mark.unit
@pytest.mark.parametrize(
    "validation_mode",
    [
        (ValidationMode.METADATA | ValidationMode.STRUCTURE),
        (ValidationMode.METADATA | ValidationMode.STRUCTURE | ValidationMode.MODEL),
        ValidationMode.NONE,
    ],
)
def test_product_is_valid(product, validation_mode):
    flag, anoms = StacProductConvention.is_valid_product(product, validation_mode=validation_mode)
    assert flag


@pytest.mark.unit
@pytest.mark.parametrize(
    "validation_mode",
    [
        (ValidationMode.METADATA | ValidationMode.STRUCTURE),
        (ValidationMode.METADATA | ValidationMode.STRUCTURE | ValidationMode.MODEL),
    ],
)
def test_product_is_invalid(invalid_product, validation_mode):
    flag, anoms = StacProductConvention.is_valid_product(invalid_product, validation_mode=validation_mode)
    print(anoms)
    assert not flag
    found_standard_error = False
    for anom in anoms:
        if anom.description.find("standard_name") != -1 and anom.description.find("invalid") != -1:
            found_standard_error = True
            print(anom)
    assert found_standard_error


@pytest.mark.unit
def test_product_structure_none_groups_skip_group_name_validation(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_validation.get_product_convention",
        lambda: NoGroupValidationConvention,
    )
    product = DataTree(name="product_name")
    product["custom"] = DataTree(name="custom")
    anomalies = []

    check_eoproduct_groups(product, anomalies, None)

    assert anomalies == []


@pytest.mark.unit
def test_product_structure_validation_rejects_convention_without_structure_protocol(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_validation.get_product_convention",
        lambda: MissingStructureProtocolConvention,
    )
    product = DataTree(name="product_name")

    with pytest.raises(TypeError, match="ProductStructureConventionProtocol"):
        check_eoproduct_groups(product, [], None)


@pytest.mark.unit
def test_product_structure_empty_groups_allow_no_top_level_groups(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_validation.get_product_convention",
        lambda: EmptyGroupValidationConvention,
    )
    product = DataTree(name="product_name")
    product["custom"] = DataTree(name="custom")
    anomalies = []

    check_eoproduct_groups(product, anomalies, None)

    assert len(anomalies) == 1
    assert "Found invalid optional groups" in anomalies[0].description


@pytest.mark.unit
def test_product_structure_none_variable_attrs_skip_attribute_validation(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_validation.get_product_convention",
        lambda: NoVariableAttributeValidationConvention,
    )
    variable = xr.DataArray(np.ones((2, 2)), name="b01")
    variable.attrs["unexpected"] = "allowed"
    anomalies = []

    check_variable_attributes(variable, anomalies, None)

    assert anomalies == []


@pytest.mark.unit
def test_product_structure_empty_variable_attrs_allow_no_variable_attrs(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_validation.get_product_convention",
        lambda: EmptyVariableAttributeValidationConvention,
    )
    variable = xr.DataArray(np.ones((2, 2)), name="b01")
    variable.attrs["unexpected"] = "not allowed"
    anomalies = []

    check_variable_attributes(variable, anomalies, None)

    assert len(anomalies) == 1
    assert "not in optional variable attributes list" in anomalies[0].description


@pytest.mark.unit
def test_product_dimensions(product):
    anomalies = []

    check_coherent_dimension_product(
        out_anomalies=anomalies,
        product=product,
        logger=None,
    )

    assert len(anomalies) == 0


@pytest.mark.unit
def test_product_invalid_dimensions(invalid_product):
    anomalies = []
    check_coherent_dimension_product(
        out_anomalies=anomalies,
        product=invalid_product,
        logger=None,
    )
    assert len(anomalies) != 0


@pytest.mark.unit
def test_product_model_processing_version_uses_product_convention(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_model.get_product_convention",
        lambda: CustomProcessingVersionConvention,
    )

    model = EOProductModel(product_type="S01SEWRAW", processing_version="PV-42", model_version="1.0.0")

    assert model.processing_version == "PV-42"


@pytest.mark.unit
def test_product_against_model(product, product_model):
    out_anoms = []
    validate_product_against_model(
        product,
        model=product_model,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    assert len(out_anoms) == 0
    print(product_model.model_dump_json(indent=4, exclude_unset=True))

    print(product_to_model(product).model_dump_json(indent=4, exclude_unset=True))


@pytest.mark.unit
def test_product_to_model(product, product_model):
    new_model = product_to_model(product)
    out_anoms = []
    validate_product_against_model(
        product,
        model=new_model,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    assert len(out_anoms) == 0
    print(new_model.model_dump_json(indent=4, exclude_unset=True))


@pytest.mark.unit
def test_product_to_model_without_stac_hook_does_not_add_stac_attrs(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_model.get_product_convention",
        lambda: GenericModelConvention,
    )
    product = DataTree(name="generic")
    product.attrs["geozarr"] = {"product_type": "GENERIC", "processing_version": "PV-1"}

    model = product_to_model(product)

    assert model.attrs == {"geozarr/product_type": AttributeModel(), "geozarr/processing_version": AttributeModel()}


@pytest.mark.unit
def test_fakeproduct_to_model(fake_quality_datatree):
    new_model = product_to_model(fake_quality_datatree)
    print(fake_quality_datatree.cpm.short_names)
    print(new_model.model_dump_json(indent=4))
    out_anoms = []
    validate_product_against_model(
        fake_quality_datatree,
        model=new_model,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    assert len(out_anoms) == 0
    print(new_model.model_dump_json(indent=4, exclude_unset=True))


@pytest.mark.unit
def test_model_to_json(product_model, OUTPUT_DIR):
    json_path = AnyPath(OUTPUT_DIR) / "model.json"
    with open(json_path.fs_path, "w") as f:
        f.write(product_model.model_dump_json(indent=4, exclude_unset=True))
    assert json_path.exists()
    data = load_json_file(json_path)
    reloaded = EOProductModel(**data)
    assert reloaded == product_model


@pytest.mark.unit
def test_json_to_model(product, EMBEDED_TEST_DATA_FOLDER_UNIT):
    json_path = Path(EMBEDED_TEST_DATA_FOLDER_UNIT) / "product" / "model_validation.json"
    data = load_json_file(json_path)
    loaded = EOProductModel(**data)
    out_anoms = []
    validate_product_against_model(
        product,
        model=loaded,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    assert len(out_anoms) == 0


@pytest.mark.unit
@pytest.mark.dask_only
def test_model_to_product(product_model):
    product = model_to_product(product_model)
    assert product is not None


@pytest.mark.unit
@pytest.mark.dask_only
def test_model_to_product_without_stac_hook_does_not_add_stac_attrs(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.datatree_product_model.get_product_convention",
        lambda: GenericModelConvention,
    )
    model = EOProductModel(attrs={"geozarr/product_type": AttributeModel()})

    product = model_to_product(model)

    assert product.attrs == {"geozarr": {"product_type": "TOBEDEFINED"}}
