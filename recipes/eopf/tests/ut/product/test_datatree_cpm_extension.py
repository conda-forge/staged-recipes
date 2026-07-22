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

import numpy as np
import pytest
from xarray import DataArray, DataTree

from eopf.exceptions import InvalidProductError
from eopf.store.mapping_manager import (
    EOPFMappingManager,
    get_short_names_from_mappings,
)

pytestmark = pytest.mark.unit


# ---------------------------------------------------------------------
# PRODUCT TYPE & VERSION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_product_type_set_get(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.product_type = "TEST-PROD"


@pytest.mark.unit
def test_product_type_empty_invalid(fake_quality_datatree):
    dt = fake_quality_datatree

    with pytest.raises(ValueError):
        dt.cpm.product_type = ""


@pytest.mark.unit
def test_product_type_blank_invalid(fake_quality_datatree):
    dt = fake_quality_datatree

    with pytest.raises(ValueError):
        dt.cpm.product_type = "   "


@pytest.mark.unit
def test_product_type_trimmed(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.product_type = " S02MSIL1C "
    assert dt.cpm.product_type == "S02MSIL1C"


@pytest.mark.unit
def test_product_id_round_trip(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.id = "S2A_MSIL2A_20200101T000000"

    assert dt.cpm.id == "S2A_MSIL2A_20200101T000000"
    assert dt.attrs["stac_discovery"]["id"] == "S2A_MSIL2A_20200101T000000"


@pytest.mark.unit
def test_processing_version_set_get(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.processing_version = "1.0.0"
    assert dt.cpm.processing_version == "1.0.0"
    assert dt.attrs["stac_discovery"]["properties"]["processing:version"] == "1.0.0"

    with pytest.raises(ValueError, match=".* is not a valid semantic version "):
        dt.cpm.processing_version = "01.0"


# ---------------------------------------------------------------------
# PRODUCT KIND
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_product_kind_default_is_product(fake_quality_datatree):
    dt = fake_quality_datatree
    assert dt.cpm.product_kind == "eoproduct"


@pytest.mark.unit
def test_product_kind_set(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.product_kind = "eocontainer"
    assert dt.cpm.product_kind == "eocontainer"
    assert dt.attrs["other_metadata"]["eopf_category"] == "eocontainer"


# ---------------------------------------------------------------------
# SHORT NAMES
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_update_short_names_from_tree(fake_quality_datatree):
    dt = fake_quality_datatree

    # Inject short_name into a variable
    for _, var in dt.cpm.walk_vars():
        var.attrs["short_name"] = "SN_TEST"
        break

    dt.cpm.rebuild_short_names_from_tree()

    assert "SN_TEST" in dt.cpm.short_names


@pytest.mark.unit
def test_short_names_returns_read_only_snapshot(fake_quality_datatree):
    dt = fake_quality_datatree

    short_names = dt.cpm.short_names

    assert "oa01_radiance" in short_names

    with pytest.raises(TypeError):
        short_names["B03"] = "measurements/radiance/oa03_radiance"


@pytest.mark.unit
def test_write_short_names_to_variables(fake_quality_datatree):
    dt = fake_quality_datatree

    dt["measurements/radiance/oa01_radiance"].attrs.pop("short_name", None)
    dt["measurements/radiance/oa02_radiance"].attrs.pop("short_name", None)
    dt.cpm.short_names = {
        "B01": "measurements/radiance/oa01_radiance",
        "B02": "measurements/radiance/oa02_radiance",
    }

    dt.cpm.write_short_names_to_variables()

    assert dt["measurements/radiance/oa01_radiance"].attrs["short_name"] == "B01"
    assert dt["measurements/radiance/oa02_radiance"].attrs["short_name"] == "B02"


@pytest.mark.unit
def test_write_short_names_to_variables_skips_invalid_paths(fake_quality_datatree):
    dt = fake_quality_datatree
    original = dt["measurements/radiance/oa01_radiance"].attrs["short_name"]
    dt.cpm.short_names = {
        "B01": "measurements/radiance/oa01_radiance",
        "BAD": "measurements/radiance/does_not_exist",
        "ALSO_BAD": "does/not/exist",
    }

    dt.cpm.write_short_names_to_variables()

    assert dt["measurements/radiance/oa01_radiance"].attrs["short_name"] == "B01"
    assert dt["measurements/radiance/oa02_radiance"].attrs["short_name"] == "oa02_radiance"
    assert original != "B01"


@pytest.mark.unit
def test_merge_short_names_from_tree_preserves_existing_and_updates_tree_values(fake_quality_datatree):
    dt = fake_quality_datatree
    dt.cpm.short_names = {
        "EXISTING": "measurements/empty_group/empty",
        "oa01_radiance": "old/path",
    }

    dt["measurements/radiance/oa01_radiance"].attrs["short_name"] = "oa01_radiance"
    dt["measurements/radiance/oa02_radiance"].attrs["short_name"] = "oa02_radiance"

    dt.cpm.merge_short_names_from_tree()

    assert dt.cpm.short_names["EXISTING"] == "measurements/empty_group/empty"
    assert dt.cpm.short_names["oa01_radiance"] == "/measurements/radiance/oa01_radiance"
    assert dt.cpm.short_names["oa02_radiance"] == "/measurements/radiance/oa02_radiance"

# ---------------------------------------------------------------------
# ATTRIBUTE SORTING
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_sort_attributes(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.attrs["zzz"] = 1  # something unordered
    dt.attrs["aaa"] = 2

    dt.cpm.sort_attributes()

    keys = list(dt.attrs.keys())

    # Required fields appear first
    assert keys[0] in ("stac_discovery",)
    assert keys[-1] == "zzz" or keys[-1] == "aaa"


# ---------------------------------------------------------------------
# PROCESSING HISTORY
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_add_processing_event(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.add_processing_event("LEVEL1", {"step": "X", "time": "2020-01-01T00:00:00Z"})

    assert "processing_history" in dt.attrs
    assert "LEVEL1" in dt.attrs["processing_history"]
    assert len(dt.attrs["processing_history"]["LEVEL1"]) == 1


def test_sort_processing_history(fake_quality_datatree):
    dt = fake_quality_datatree

    dt.cpm.add_processing_event("Level-1 Product", {"time": "2020-01-02T00:00:00Z"})
    dt.cpm.add_processing_event("Level-0 Product", {"time": "2020-01-01T00:00:00Z"})
    dt.cpm.sort_attributes()
    dt.cpm.sort_processing_history()

    levels = list(dt.attrs["processing_history"].keys())
    assert levels == ["Level-0 Product", "Level-1 Product"]  # chronological order


# ---------------------------------------------------------------------
# WALKING
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_walk(fake_quality_datatree):
    dt = fake_quality_datatree
    nodes = list(dt.cpm.walk())
    assert len(nodes) >= 1
    assert isinstance(nodes[0], DataTree)


@pytest.mark.unit
def test_walk_vars(fake_quality_datatree):
    dt = fake_quality_datatree
    vars_collected = list(dt.cpm.walk_vars())

    assert len(vars_collected) >= 1
    full_path, var = vars_collected[0]

    assert isinstance(full_path, str)
    assert isinstance(var, DataArray)


# ---------------------------------------------------------------------
# RESOLUTION
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_resolve_node(fake_quality_datatree):
    dt = fake_quality_datatree
    first_child_name = next(iter(dt.children.keys()))

    resolved = dt.cpm.resolve(first_child_name)
    assert isinstance(resolved, DataTree)


@pytest.mark.unit
def test_resolve_variable(fake_quality_datatree):
    dt = fake_quality_datatree
    path, var = next(dt.cpm.walk_vars())
    resolved = dt.cpm.resolve(path)
    assert isinstance(resolved, DataArray)


# ---------------------------------------------------------------------
# DASK GRAPH EXPORT
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_export_dask_graph(tmp_path, fake_quality_datatree):
    dt = fake_quality_datatree
    dt.cpm.export_dask_graph(folder=str(tmp_path))

    files = list(tmp_path.glob("*.svg"))
    assert len(files) >= 0  # at least no crash


# ---------------------------------------------------------------------
# DATASIZE
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_datasize(fake_quality_datatree):
    dt = fake_quality_datatree
    size = dt.cpm.datasize()
    assert isinstance(size, int)
    assert size > 0


@pytest.mark.unit
def test_datasize_computes_exact_data_and_coord_bytes():
    product = DataTree(name="product")
    product.attrs["mission"] = "S2"
    product["measurements"] = DataTree(
        name="measurements",
        dataset=DataArray(
            np.array([[1, 2, 3], [4, 5, 6]], dtype=np.int16),
            dims=("y", "x"),
            coords={
                "x": np.array([10, 20, 30], dtype=np.int32),
                "y": np.array([1, 2], dtype=np.uint8),
            },
            name="signal",
        ).to_dataset(),
    )
    product["measurements"].attrs["level"] = 1
    product["quality"] = DataTree(
        name="quality",
        dataset=DataArray(np.array([True, False], dtype=np.bool_), dims=("y",), name="mask").to_dataset(),
    )

    expected_attrs_size = len(json.dumps({"mission": "S2"}).encode("utf-8")) + len(
        json.dumps({"level": 1}).encode("utf-8"),
    )

    assert product.cpm.datasize() == 28 + expected_attrs_size


# ---------------------------------------------------------------------
# FILTER VARIABLES
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_filter_variables(fake_quality_datatree):
    dt = fake_quality_datatree

    all_vars = list(dt.cpm.walk_vars())
    assert len(all_vars) > 0
    keep = [all_vars[0][0]]

    out = dt.cpm.filter_variables(keep)

    kept = list(out.cpm.walk_vars())
    assert len(kept) == 1
    assert kept[0][0] == keep[0]


# ---------------------------------------------------------------------
# shortnames
# ---------------------------------------------------------------------


@pytest.fixture
def mapping_filename(request) -> str:
    return request.getfixturevalue(request.param)


@pytest.mark.unit
@pytest.mark.parametrize(
    "mapping_filename, expected_invalid",
    [
        #    ("S01SIWOCN_MAPPING",2),
        # todo: temporary : until S2 mapping fix
        (
            "S03MWRL0__MAPPING",
            23,
        ),  # invalid for other_metadata, processing_history and stac_discovery
    ],
    indirect=["mapping_filename"],
)
def test_datatree_short_names_from_mappings(fake_quality_datatree, mapping_filename, expected_invalid):
    # "", "/" target_path , and single target multi mapping short name collision are expected_invalid.
    # short name colision on different target_path  are the main other cause of real invalid short_names

    with open(mapping_filename) as f:
        mappin_data = json.load(f)
        mapping_short_name_count = 0
        mapping_short_name_not_optional = 0
        for eo_obj_description in mappin_data["data_mapping"]:
            if "short_name" in eo_obj_description:
                mapping_short_name_count += 1
                if "is_optional" in eo_obj_description and eo_obj_description["is_optional"] is True:
                    pass
                else:
                    mapping_short_name_not_optional += 1
        type = mappin_data["product_type"]
        version = mappin_data["processing_version"]

    shortnames = get_short_names_from_mappings(
        mapping_manager=EOPFMappingManager(),
        product_type=type,
        processing_version=version,
    )
    fake_quality_datatree.cpm.short_names = shortnames
    assert len(fake_quality_datatree.cpm.short_names) >= mapping_short_name_not_optional


@pytest.mark.unit
def test_datatree_short_names(fake_quality_datatree):
    print(fake_quality_datatree.cpm.short_names)
    assert fake_quality_datatree.cpm.get_item("oa01_radiance") is not None


# ---------------------------------------------------------------------
# product_id
# ---------------------------------------------------------------------


@pytest.mark.unit
def test_get_product_id(fake_quality_datatree):
    print(fake_quality_datatree.cpm.product_id())
    assert fake_quality_datatree.cpm.product_id() == "FAKEONE_20220614T130043_0717_A238_TF09"
    assert not fake_quality_datatree.cpm.product_id().endswith("_")
    assert fake_quality_datatree.cpm.product_id("T248").endswith(
        "_T248",
    )


@pytest.mark.unit
def test_get_product_id_error_case(fake_quality_datatree):
    new_prod = fake_quality_datatree.copy()
    new_prod.attrs.pop("stac_discovery")
    with pytest.raises(InvalidProductError):
        new_prod.cpm.product_id()


# ---------------------------------------------------------------------
# writing
# ---------------------------------------------------------------------
@pytest.mark.unit
def test_to_zarr(fake_quality_datatree, tmp_path):
    output_path = tmp_path / "out.zarr"
    fake_quality_datatree.cpm.to_zarr(output_path)
    assert output_path.exists()
