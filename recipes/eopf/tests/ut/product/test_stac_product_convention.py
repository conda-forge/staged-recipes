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

from eopf.common.constants import EOCONTAINER_CATEGORY, EOPRODUCT_CATEGORY
from eopf.product.product_stac_convention import StacProductConvention


@pytest.mark.unit
def test_stac_product_type_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    StacProductConvention.set_product_type(dt, " S02MSIL2A ")

    assert StacProductConvention.product_type(dt) == "S02MSIL2A"
    assert dt.attrs["stac_discovery"]["properties"]["product:type"] == "S02MSIL2A"


@pytest.mark.unit
def test_stac_product_kind_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    StacProductConvention.set_product_kind(dt, EOCONTAINER_CATEGORY)

    assert StacProductConvention.product_kind(dt) == EOCONTAINER_CATEGORY
    assert dt.attrs["other_metadata"]["eopf_category"] == EOCONTAINER_CATEGORY

    StacProductConvention.set_product_kind(dt, EOPRODUCT_CATEGORY)

    assert StacProductConvention.product_kind(dt) == EOPRODUCT_CATEGORY


@pytest.mark.unit
def test_stac_processing_version_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    StacProductConvention.set_processing_version(dt, "1.0.0")

    assert StacProductConvention.processing_version(dt) == "1.0.0"
    assert dt.attrs["stac_discovery"]["properties"]["processing:version"] == "1.0.0"


@pytest.mark.unit
def test_stac_processing_software_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree.copy()

    StacProductConvention.clear_processing_software(dt)

    assert len(StacProductConvention.processing_software(dt)) == 0

    StacProductConvention.add_processing_software_entry(dt, "soft-a", "1.0.0")
    StacProductConvention.add_processing_software_entry(dt, "soft-b", "2.0.0")

    assert StacProductConvention.processing_software(dt) == {
        "soft-a": "1.0.0",
        "soft-b": "2.0.0",
    }

    StacProductConvention.remove_processing_software_entry(dt, "soft-a")
    assert StacProductConvention.processing_software(dt) == {"soft-b": "2.0.0"}

    StacProductConvention.clear_processing_software(dt)
    assert StacProductConvention.processing_software(dt) == {}


@pytest.mark.unit
def test_stac_processing_software_version_accepts_non_semver(fake_quality_datatree):
    dt = fake_quality_datatree.copy()
    StacProductConvention.clear_processing_software(dt)

    StacProductConvention.add_processing_software_entry(dt, "processor", "IPF_002.71")

    assert StacProductConvention.processing_software(dt) == {"processor": "IPF_002.71"}


@pytest.mark.unit
def test_stac_processing_software_version_rejects_empty(fake_quality_datatree):
    dt = fake_quality_datatree.copy()

    with pytest.raises(ValueError, match="cannot be empty"):
        StacProductConvention.add_processing_software_entry(dt, "processor", " ")


@pytest.mark.unit
def test_stac_assets_helpers_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    StacProductConvention.set_asset(dt, " B02 ", {"href": "path/to/B02.tif"})

    asset = StacProductConvention.get_asset(dt, "B02")
    assert asset == {"href": "path/to/B02.tif"}

    assets = StacProductConvention.assets(dt)
    assert assets["B02"] == {"href": "path/to/B02.tif"}

    StacProductConvention.populate_assets_with_shortnames(
        dt,
        {"B03": "measurements/radiance/oa03_radiance"},
    )
    assert StacProductConvention.get_asset(dt, "B03") == {
        "href": "measurements/radiance/oa03_radiance",
        "title": "B03",
    }

    StacProductConvention.remove_asset(dt, "B02")
    assert StacProductConvention.get_asset(dt, "B02") is None

    StacProductConvention.clear_assets(dt)
    assert StacProductConvention.assets(dt) == {}


@pytest.mark.unit
def test_stac_product_id_uses_product_type(fake_quality_datatree):
    dt = fake_quality_datatree
    StacProductConvention.set_product_type(dt, "FAKEONE")
    dt.attrs["stac_discovery"]["properties"]["product:timeliness_category"] = "NRT"

    product_id = StacProductConvention.product_id(dt)

    assert product_id.startswith("FAKEONE_")


@pytest.mark.unit
def test_stac_product_id_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    StacProductConvention.set_id(dt, "S2A_MSIL2A_20200101T000000")

    assert StacProductConvention.id(dt) == "S2A_MSIL2A_20200101T000000"
    assert dt.attrs["stac_discovery"]["id"] == "S2A_MSIL2A_20200101T000000"


@pytest.mark.unit
def test_stac_eoqc_report_additional_info(fake_quality_datatree):
    dt = fake_quality_datatree

    assert StacProductConvention.eoqc_report_additional_info(dt) == {
        "start_datetime": "2022-06-14T13:00:43.45Z",
        "end_datetime": "2022-06-14T13:12:40.45Z",
        "relative_orbit": 238,
        "absolute_orbit": 32936,
    }
