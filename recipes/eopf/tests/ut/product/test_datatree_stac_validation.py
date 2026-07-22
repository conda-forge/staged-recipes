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
from xarray import DataTree

from eopf.product.datatree_stac_validation import (
    MANDATORY_STAC_ATTR,
    check_stac_geometry,
    check_stac_mandatory_list,
    check_stac_validity,
    extract_stac_extensions,
)


@pytest.mark.unit
def test_extract_stac_extensions_parses_urls():
    stac = {
        "stac_extensions": [
            "https://example.org/extensions/eopf-stac-extension/v1.0.0/schema.json",
        ],
    }

    res = extract_stac_extensions(stac, None)

    assert "eopf-stac-extension" in res
    name, version, url = res["eopf-stac-extension"]
    assert name == "eopf-stac-extension"
    assert version == "v1.0.0"


@pytest.mark.unit
def test_check_stac_mandatory_list_reports_missing():
    anomalies = []
    stac = {}

    check_stac_mandatory_list(stac, anomalies, None)

    assert len(anomalies) == len(MANDATORY_STAC_ATTR)


@pytest.mark.unit
def test_check_stac_geometry_polygon_open_ring():
    anomalies = []
    stac = {
        "geometry": {
            "type": "Polygon",
            "coordinates": [[[0, 0], [1, 1], [2, 2]]],
        },
    }

    check_stac_geometry(stac, anomalies, None)
    assert len(anomalies) == 1
    assert "not closed" in anomalies[0].description


@pytest.mark.unit
def test_check_stac_geometry_polygon_ok():
    anomalies = []
    stac = {
        "geometry": {
            "type": "Polygon",
            "coordinates": [[[0, 0], [1, 1], [2, 2], [0, 0]]],
        },
    }
    check_stac_geometry(stac, anomalies, None)
    assert anomalies == []


@pytest.mark.unit
def test_check_stac_validity_no_stac_discovery():
    anomalies = []
    product = DataTree()

    check_stac_validity(product, anomalies, None)

    assert len(anomalies) == 1
    assert "No stac_discovery" in anomalies[0].description


@pytest.mark.unit
def test_check_stac_validity_bad_type():
    anomalies = []
    product = DataTree()
    product.attrs.update({"stac_discovery": 123})

    check_stac_validity(product, anomalies, None)

    assert len(anomalies) == 1
    assert "not a dict" in anomalies[0].description
