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
import gc
import os
import shutil
from pathlib import Path
from typing import Any, Type

import numpy as np
import pytest
import xarray
import zarr
from s3fs import S3FileSystem
from xarray import DataArray, DataTree

from eopf.common.constants import EOCONTAINER_CATEGORY, SHORT_NAME, ZARR_EOV_ATTRS
from eopf.common.functions_utils import change_working_dir
from eopf.product.conveniences import init_datatree
from eopf.store.abstract import EOReader
from eopf.store.zarr_reader import EODataTreeZarrReader
from eopf.store.zarr_writer import EODataTreeZarrWriter
from tests.conftest import TEST_DATA_PATH
from tests.test_utils import assert_contain


@pytest.mark.need_files
@pytest.mark.unit
def test_zarr_read():
    input_file = Path(TEST_DATA_PATH) / "olci_zarr_test.zarr"
    dtree = EODataTreeZarrReader().open_datatree(filename_or_obj=input_file)
    dtree_c = dtree.compute()
    assert dtree_c


@pytest.mark.unit
@pytest.mark.real_s3
def test_zarr_read_s3(s3_test_data, s3_config_real):
    input_file = f"{s3_test_data[0]}://{s3_test_data[1]}/olci_zarr_test.zarr"
    dtree = EODataTreeZarrReader().open_datatree(filename_or_obj=input_file, storage_options=s3_config_real)
    assert dtree
    dtree.load()
    dtree_c = dtree.compute()
    assert dtree_c
    dtree.close()
    del dtree
    S3FileSystem.clear_instance_cache()
    gc.collect()


@pytest.mark.unit
@pytest.mark.real_s3
def test_zarr_read_obstore(s3_test_data, obstore_s3_config_real):
    from obstore.store import S3Store
    from zarr.storage import ObjectStore

    input_file = f"{s3_test_data[0]}://{s3_test_data[1]}/olci_zarr_test.zarr"
    store = S3Store.from_url(input_file, config=obstore_s3_config_real)
    dtree = EODataTreeZarrReader().open_datatree(filename_or_obj=ObjectStore(store))
    assert dtree
    dtree.load()
    dtree_c = dtree.compute()
    assert dtree_c
    dtree.close()
    del dtree
    gc.collect()


@pytest.mark.real_s3
@pytest.mark.unit
@pytest.mark.parametrize(
    "store, raw_path",
    [
        (
                EODataTreeZarrReader,
            "S3_TEST_DATA_FOLDER/olci_zarr_test_nothere.zarr.zip",
        ),
        (
                EODataTreeZarrReader,
            "S3_TEST_DATA_FOLDER/olci_zarr_test_nothere.zarr",
        ),
        # (
        #     EODataTreeSafeStore,
        #     "zip::S3_TEST_DATA_FOLDER/"
        #     "S3A_OL_1_EFR____20200101T101517_20200101T101817_20200102T1411"
        #     "02_0179_053_179_2520_LN1_O_NT_002_nothere.zip",
        # ),
    ],
)
def test_read_real_s3_not_found(
    store: Type[EOReader],
    raw_path: str,
    s3_test_data: tuple[str | None, str],
    s3_config_real: dict[str, Any],
) -> None:
    protocol, base_path = s3_test_data

    if protocol is None:
        raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")

    path = raw_path.replace("S3_TEST_DATA_FOLDER", f"{protocol}://{base_path}")
    print("path", path)

    with pytest.raises(FileNotFoundError):
        store().open_datatree(
            filename_or_obj=path,
            storage_options=s3_config_real,
        )


_FILES = {
    "json": "test_metadata_file_.json",
    "zarr": "test_zarr_files_.zarr",
    "zarr0": "test_zarr_read_files_.zarr",
    "zarr1": "test_zarr_write_files_.zarr",
    "zarrcontainer": "test_zarr_container.zarr",
    "notfound": "test_not_here",
}


@pytest.fixture
def setup_and_cleanup_files(FOLDER_WITH_CONFIGS, EMBEDED_TEST_DATA_FOLDER_UNIT):
    yield
    for file in _FILES.values():
        if os.path.isfile(file):
            try:
                os.remove(file)
            except PermissionError:
                pass
        if os.path.isdir(file):
            shutil.rmtree(file)


@pytest.fixture
def zarr_product_written_on_disk(setup_and_cleanup_files, tmp_path: Path):
    file_path = tmp_path / _FILES["zarr"]
    file_path.mkdir(exist_ok=True)
    file_name = str(file_path)
    assert file_path.exists()

    dims = "_ARRAY_DIMENSIONS"
    shn = SHORT_NAME
    eova = ZARR_EOV_ATTRS

    root = zarr.open_group(file_name, mode="w")
    root.attrs["top_level"] = True
    root.attrs["other_metadata"] = {"eopf_category": "eoproduct"}
    root.create_group("coordinates")

    root["coordinates"].attrs["description"] = "coordinates Data Group"
    root["coordinates"].create_group("grid")
    root["coordinates"].create_group("tie_point")
    xarray.Dataset(
        {
            "radiance": (("rows", "columns"), np.zeros((2, 3))),
            "orphan": (("depths", "length"), np.zeros((2, 3))),
        },
    ).to_zarr(
        store=f"{file_name}/coordinates/grid",
        mode="a",
    )
    xarray.Dataset(
        {
            "radiance": (("rows", "columns"), np.zeros((2, 3))),
            "orphan": (("depths", "length"), np.zeros((2, 3))),
        },
    ).to_zarr(
        store=f"{file_name}/coordinates/tie_point",
        mode="a",
    )

    root.create_group("measurements")
    root["measurements"].attrs["description"] = "measurements Data Group"
    root["measurements"].create_group("geo_position")
    root["measurements"]["geo_position"].create_group("altitude")
    root["measurements"]["geo_position"].create_group("latitude")
    root["measurements"]["geo_position"].create_group("longitude")

    xarray.Dataset(
        {
            "polarian": xarray.DataArray(
                [[12, 4], [3, 8]],
                attrs={dims: ["rows", "dim2"], eova: {shn: "alt_pol"}},
            ),
            "cartesian": xarray.DataArray(
                [[5, -3], [-55, 66]],
                attrs={dims: ["rows", "dim2"], eova: {shn: "alt_cart"}},
            ),
        },
    ).to_zarr(store=f"{file_name}/measurements/geo_position/altitude", mode="a")
    xarray.Dataset(
        {
            "polarian": xarray.DataArray(
                [[1, 2], [3, 4]],
                attrs={dims: ["rows", "dim2"], eova: {shn: "lat_pol"}},
            ),
            "cartesian": xarray.DataArray(
                [[9, 7], [-12, 81]],
                attrs={dims: ["rows", "dim2"], eova: {shn: "lat_cart"}},
            ),
        },
    ).to_zarr(store=f"{file_name}/measurements/geo_position/latitude", mode="a")
    xarray.Dataset(
        {
            "polarian": xarray.DataArray(
                [[6, 7, 8], [2, 1, -6]],
                attrs={dims: ["rows", "columns"], eova: {shn: "lon_pol"}},
            ),
            "cartesian": xarray.DataArray(
                [[25, 0, 11], [-5, 72, 44]],
                attrs={dims: ["rows", "columns"], eova: {shn: "lon_cart"}},
            ),
        },
    ).to_zarr(store=f"{file_name}/measurements/geo_position/longitude", mode="a")
    zarr.consolidate_metadata(root.store)

    return file_name


@pytest.fixture
def zarr_container_written_on_disk(setup_and_cleanup_files, tmp_path: Path):
    container = DataTree(name="test")
    container.cpm.product_kind = EOCONTAINER_CATEGORY
    container.attrs = {"stac_discovery": {"properties": {"product:type": "S02MSIL1C"}}}

    attrs = {
        "stac_discovery": {
            "properties": {
                "product:type": "S02MSIL1C",
                "start_datetime": "2021-01-01T01:01:01",
                "end_datetime": "2021-01-01T01:01:01",
                "platform": "S2B",
                "sat:relative_orbit": 128,
                "product:timeline": "NR",
            },
        },
    }

    container["test"] = init_datatree("test", attrs=attrs)
    sub_container = DataTree(name="subcont")
    sub_container.cpm.product_kind = EOCONTAINER_CATEGORY
    sub_container["subprod"] = init_datatree("subprod", attrs=attrs)
    container["subcont"] = sub_container
    file_name = str(tmp_path / _FILES["zarrcontainer"])
    print(f"writing container {file_name}")
    EODataTreeZarrWriter().write(container, file_name)
    return f"file://{file_name}"


@pytest.mark.unit
def test_load_product_from_zarr(dask_context, zarr_product_written_on_disk: str):
    product = EODataTreeZarrReader().open_datatree(filename_or_obj=zarr_product_written_on_disk)
    validate_zarr_product_load(product)


@pytest.mark.unit
def test_load_product_from_relative(dask_context, zarr_product_written_on_disk: str):
    zarr_product_path = Path(zarr_product_written_on_disk)
    with change_working_dir(str(zarr_product_path.parent)):
        print(os.getcwd())
        product = EODataTreeZarrReader().open_datatree(filename_or_obj=f"./{zarr_product_path.name}")
        validate_zarr_product_load(product)


@pytest.mark.unit
def test_load_product_from_zarr_getitem(dask_context, zarr_product_written_on_disk: str):
    product = EODataTreeZarrReader().open_datatree(filename_or_obj=zarr_product_written_on_disk)
    validate_zarr_product_load(product)


@pytest.mark.unit
def test_load_container_from_zarr(zarr_container_written_on_disk: str):
    print(f"store: {zarr_container_written_on_disk}")
    container = EODataTreeZarrReader().open_datatree(filename_or_obj=zarr_container_written_on_disk)
    print(f"zarr_container {zarr_container_written_on_disk}")
    assert len(container) == 2
    for x in container:
        print(x)
        assert isinstance(container[x], DataTree)


@pytest.mark.unit
def test_load_container_from_zarr_2(
    zarr_container_written_on_disk: str,
):
    zarr_container_path = Path(zarr_container_written_on_disk.removeprefix("file://"))
    print(f"store: {zarr_container_written_on_disk} from {str(zarr_container_path)}")
    container = EODataTreeZarrReader().open_datatree(filename_or_obj=zarr_container_path)
    print(f"zarr_container_path {zarr_container_path}")
    assert len(container) == 2
    for x in container.keys():
        assert isinstance(container[x], DataTree)


@pytest.mark.real_s3
@pytest.mark.unit
@pytest.mark.parametrize(
    "store, raw_path",
    [
        (
                EODataTreeZarrReader,
            "S3_TEST_DATA_FOLDER/test_zarr_container.zarr",
        ),
    ],
)
def test_read_container_s3(
    dask_context,
    store: Type[EOReader],
    raw_path: str,
    s3_test_data: tuple[str | None, str],
    s3_config_real: dict[str, Any],
) -> None:
    protocol, base_path = s3_test_data

    if protocol is None:
        raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")

    path = raw_path.replace("S3_TEST_DATA_FOLDER", f"{protocol}://{base_path}")

    print(f"Opening : {path}")

    cont = store().open_datatree(
        path,
        storage_options=s3_config_real,
    )

    assert cont
    print(cont)


def validate_zarr_product_load(product: DataTree):
    assert product.attrs["top_level"]
    assert_contain(product, "measurements", DataTree)
    assert product["measurements"].attrs["description"] == "measurements Data Group"
    assert_contain(product.measurements, "geo_position", DataTree, "/measurements/")
    assert_contain(
        product.measurements.geo_position,
        "altitude",
        DataTree,
        "/measurements/geo_position/",
    )
    assert_contain(
        product.measurements.geo_position,
        "latitude",
        DataTree,
        "/measurements/geo_position/",
    )
    assert_contain(
        product.measurements.geo_position,
        "longitude",
        DataTree,
        "/measurements/geo_position/",
    )
    assert_contain(
        product.measurements.geo_position.altitude,
        "polarian",
        DataArray,
        "/measurements/geo_position/altitude/",
    )
    assert_contain(
        product.measurements.geo_position.altitude,
        "cartesian",
        DataArray,
        "/measurements/geo_position/altitude/",
    )
    # assert_has_coords(product.measurements.geo_position.altitude.cartesian, coords)
    assert_contain(
        product.measurements.geo_position.latitude,
        "polarian",
        DataArray,
        "/measurements/geo_position/latitude/",
    )
    # assert_has_coords(product.measurements.geo_position.latitude.polarian, coords)
    assert_contain(
        product.measurements.geo_position.latitude,
        "cartesian",
        DataArray,
        "/measurements/geo_position/latitude/",
    )
    # assert_has_coords(product.measurements.geo_position.latitude.cartesian, coords)
    assert_contain(
        product.measurements.geo_position.longitude,
        "polarian",
        DataArray,
        "/measurements/geo_position/longitude/",
    )
    # assert_has_coords(product.measurements.geo_position.longitude.polarian, coords)
    assert_contain(
        product.measurements.geo_position.longitude,
        "cartesian",
        DataArray,
        "/measurements/geo_position/longitude/",
    )
    # assert_has_coords(product.measurements.geo_position.longitude.cartesian, coords)
    with pytest.raises(KeyError):
        assert_contain(product, "measurements/group2", DataTree)
    with pytest.raises(KeyError):
        assert_contain(product, "measurements/group1/variable_d", DataArray)

    # TODO retest short names after short names update
    # check short_name
    # shn = product.short_names
    # ref_shn = {
    #     "alt_pol": "measurements/geo_position/altitude/polarian",
    #     "alt_cart": "measurements/geo_position/altitude/cartesian",
    #     "lat_pol": "measurements/geo_position/latitude/polarian",
    #     "lat_cart": "measurements/geo_position/latitude/cartesian",
    #     "lon_pol": "measurements/geo_position/longitude/polarian",
    #     "lon_cart": "measurements/geo_position/longitude/cartesian",
    # }
    # for key, target in ref_shn.items():
    #     assert shn.get(key) == target

    # # check the short name is present in variable attributes
    # for key in ref_shn:
    #     assert SHORT_NAME in product[key].attrs
