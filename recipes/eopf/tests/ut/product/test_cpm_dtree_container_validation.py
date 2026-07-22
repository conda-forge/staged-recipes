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
from copy import deepcopy
from pathlib import Path

import numpy as np
import pytest
import xarray as xr
from xarray import DataTree

from eopf.common.constants import EOCONTAINER_CATEGORY, EOPRODUCT_CATEGORY
from eopf.common.file_utils import load_json_file
from eopf.product.datatree_container_model import (
    EOContainerModel,
    container_to_model,
    model_to_container,
)
from eopf.product.datatree_container_validation import (
    validate_container_against_model,
)
from eopf.product.datatree_product_model import EOProductModel, EOVariableModel
from eopf.product.datatree_validation import AttributeModel, ValidationMode
from eopf.product.product_stac_convention import StacProductConvention
from eopf.product.structure_convention_protocol import StacProductStructureConventionMixin


@pytest.fixture
def container() -> DataTree:
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
            "collection": {},
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
    product.cpm.product_kind = EOPRODUCT_CATEGORY
    container = DataTree(name="container_name")
    container.attrs = deepcopy(product.attrs)

    container.cpm.product_type = "S3SLSLSTC"
    container.cpm.product_kind = EOCONTAINER_CATEGORY
    container["product"] = product
    return container


@pytest.fixture
def container_model() -> EOContainerModel:
    return EOContainerModel(
        product_type="S3SLSLSTC",
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
            "other_metadata/eopf_category": AttributeModel(),
            "stac_discovery/properties/processing:software": AttributeModel(
                required=False,
                dont_look_under=True,
            ),
        },
        sub_products={
            "product.*": EOProductModel(
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
                    "processing_history": AttributeModel(
                        required=False,
                        dont_look_under=True,
                    ),
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
            ),
        },
    )


@pytest.mark.unit
@pytest.mark.parametrize(
    "validation_mode",
    [
        (ValidationMode.STRUCTURE),
        (ValidationMode.METADATA | ValidationMode.STRUCTURE),
        (ValidationMode.STRUCTURE | ValidationMode.MODEL),
        (ValidationMode.METADATA | ValidationMode.STRUCTURE | ValidationMode.MODEL),
        ValidationMode.NONE,
    ],
)
def test_container_is_valid(container, validation_mode):
    print(container.attrs)
    flag, anom = StacProductConvention.is_valid_container(container, validation_mode=validation_mode)
    print(anom)
    assert flag


@pytest.mark.unit
def test_container_against_model(container, container_model):
    out_anoms = []
    validate_container_against_model(
        container,
        model=container_model,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    print(container_model.model_dump_json(indent=4, exclude_unset=True))
    assert len(out_anoms) == 0

    print(container_to_model(container).model_dump_json(indent=4, exclude_unset=True))


@pytest.mark.unit
def test_container_to_model(container):
    new_model = container_to_model(container)
    out_anoms = []
    validate_container_against_model(
        container,
        model=new_model,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    print(new_model.model_dump_json(indent=4, exclude_unset=True))

    assert len(out_anoms) == 0


@pytest.mark.unit
def test_model_to_json(container_model, OUTPUT_DIR):
    json_path = Path(OUTPUT_DIR) / "container_model.json"
    with open(json_path, "w") as f:
        f.write(container_model.model_dump_json(indent=4, exclude_unset=True))
    assert json_path.exists()
    data = load_json_file(json_path)
    reloaded = EOContainerModel(**data)
    assert reloaded == container_model


@pytest.mark.unit
def test_json_to_model(container, EMBEDED_TEST_DATA_FOLDER_UNIT):
    json_path = Path(EMBEDED_TEST_DATA_FOLDER_UNIT) / "product" / "container_model_validation.json"
    data = load_json_file(json_path)
    loaded = EOContainerModel(**data)
    out_anoms = []
    validate_container_against_model(
        container,
        model=loaded,
        mode="EXACT",
        out_anomalies=out_anoms,
        logger=logging.getLogger("eopf.test.validate_model"),
    )
    assert len(out_anoms) == 0


@pytest.mark.unit
@pytest.mark.dask_only
def test_model_to_container(container_model):
    container = model_to_container(container_model)
    assert container is not None
