import datetime
import shutil
from pathlib import Path
from typing import Any

import numpy as np
import pytest

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")

import xarray as xr
from pytest import MonkeyPatch
from xarray import DataArray, Dataset, DataTree, open_datatree

from eopf.computing import merge
from eopf.computing.merge import (
    OPEN_DATASET_KWARGS,
    open_and_combine_tiles,
    sanity_check,
)

FLAG_NODATA = 0
FLAG_OPAQUE = 1
FLAG_CIRRUS = 2
FLAG_SNOW_ICE = 3


def create_tile_da(
    x_length: int,
    y_length: int,
    x_shift: int,
    y_shift: int,
    resolution: int,
    value: Any,
    name: str,
) -> DataArray:
    x = np.arange(0, x_length + 1, resolution) + x_shift
    y = np.arange(0, y_length + 1, resolution) + y_shift

    da = DataArray(
        np.full((x.size, y.size), value),
        coords={"x": x, "y": y},
        name=name,
    )

    da = da.sortby("y", ascending=False)
    da = da.chunk({dim: size // 2 for dim, size in da.sizes.items()})
    da.attrs = {"foo": "foo", "timestamp": datetime.datetime.now().isoformat()}
    return da


def create_tile_l1c_classification_mask(
    x_length: int,
    y_length: int,
    x_shift: int,
    y_shift: int,
    resolution: int,
    value: Any,
    name: str,
) -> DataArray:
    x = np.arange(0, x_length + 1, resolution) + x_shift
    y = np.arange(0, y_length + 1, resolution) + y_shift

    size = 10 if value == 0 else 20
    opaque = np.full(
        (
            size,
            x.size,
        ),
        FLAG_OPAQUE,
    )
    cirrus = np.full(
        (
            size,
            x.size,
        ),
        FLAG_CIRRUS,
    )
    snow = np.full((size, x.size), FLAG_SNOW_ICE)
    nodata = np.full((y.size - size * 3, x.size), FLAG_NODATA)
    array = np.vstack((opaque, cirrus, snow, nodata))

    da = DataArray(
        array,
        coords={"x": x, "y": y},
        name=name,
    )

    da = da.sortby("y", ascending=False)
    da.attrs = {
        "flag_masks": [FLAG_OPAQUE, FLAG_CIRRUS, FLAG_SNOW_ICE],
        "flag_meanings": ["OPAQUE", "CIRRUS", "SNOW_ICE"],
    }
    da = da.chunk({dim: size // 2 for dim, size in da.sizes.items()})
    return da


def create_tile_sun_angles(
    x_length: int,
    y_length: int,
    x_shift: int,
    y_shift: int,
    resolution: int,
    value: Any,
    name: str,
) -> DataArray:
    x = np.arange(0, x_length + 1, resolution) + x_shift
    y = np.arange(0, y_length + 1, resolution) + y_shift

    zenith = np.full(
        (
            y.size,
            x.size,
        ),
        1.0 * value,
    )
    azimuth = np.full(
        (
            y.size,
            x.size,
        ),
        2.0 * value,
    )
    array = [zenith, azimuth]

    da = DataArray(
        array,
        coords={"angle": ["zenith", "azimuth"], "x": x, "y": y},
        name="sun_angles",
    )

    da = da.sortby("y", ascending=False)
    da = da.chunk({dim: size // 2 for dim, size in da.sizes.items()})
    return da


@pytest.fixture
def input_dir(tmp_path: Path) -> str:
    length = 1_200

    path = tmp_path / "tiles"
    path.mkdir()
    counter = 0
    for x_shift in [0, 1_050]:
        for y_shift in [0, 900]:
            counter += 1
            datatree_dict = {}

            # Geometry
            da = create_tile_da(
                x_length=length,
                y_length=length,
                x_shift=x_shift,
                y_shift=y_shift,
                resolution=50,
                value=np.array(counter, dtype="uint8"),
                name="foo",
            )
            da = da.expand_dims(foo_dim=[1, 2])
            ds = da.to_dataset()
            ds["bar"] = da.mean(["x", "y"])
            datatree_dict["/conditions/geometry"] = ds

            for resolution in (1, 2, 6):
                da = create_tile_da(
                    x_length=length,
                    y_length=length,
                    x_shift=x_shift,
                    y_shift=y_shift,
                    resolution=resolution,
                    value=float(counter),
                    name="foo",
                )
                ds = da.to_dataset()
                datatree_dict[f"/measurements/reflectance/r{resolution}m"] = ds

            datasets = []
            for resolution in (1, 2, 6):
                da = create_tile_da(
                    x_length=length,
                    y_length=length,
                    x_shift=x_shift,
                    y_shift=y_shift,
                    resolution=resolution,
                    value=np.array(counter, dtype="uint8"),
                    name=f"foo_{resolution}m",
                )
                da = da.rename(
                    {dim: dim.replace(dim, f"{dim}_{resolution}m") for dim in da.dims if isinstance(dim, str)},
                )
                datasets.append(da.to_dataset())
            ds = xr.merge(datasets)
            datatree_dict["/quality"] = ds

            if counter % 2:
                datatree_dict["/"] = Dataset(
                    attrs={
                        "stac_discovery": {
                            "id": counter,
                            "properties": {
                                "product:type": "S02MSIL1C",
                                "eo:cloud_cover": 100.0,
                                "eo:snow_cover": 100.0,
                                "processing:version": "04.00",
                                "start_datetime": "2021-01-01T01:01:01",
                                "end_datetime": "2021-01-01T01:01:01",
                                "platform": "S2B",
                                "sat:relative_orbit": 128,
                                "product:timeliness_category": "NR",
                                "product:timeliness": "PT3H",
                            },
                        },
                        "test_string_ok": "abc",
                        "test_list_ok": ["abc", "def"],
                        "differents_values": {
                            "test_int": 2,
                            "test_float": 1.5,
                            "test_string_ok": "abc",
                            "test_string_nok": "abc",
                            "test_date": "2025-02-19T12:04:05.890464Z",
                            "test_list_ok": ["abc", "def"],
                            "test_list_ko1": ["abc", "def"],
                            "test_list_ko2": ["abc", "def"],
                            "dict_other": {"dict_str": "xyz", "dict_list": [{"dict_list_str": "test1"}]},
                            "bbox": [-3.992785161066348, 62.13068971471457, -4.933827079364661, 62.3653862905382],
                            "proj:bbox": [399960.0, 6790200.0, 509760.0, 6900000.0],
                            "coordinates": [
                                [
                                    [counter % 2, 0],
                                    [counter % 2, 2],
                                    [counter % 2 + 1, 2],
                                    [counter % 2 + 1, 0],
                                    [counter % 2, 0],
                                ],
                            ],
                        },
                        "no_corres_1": "test",
                    },
                )
            else:
                datatree_dict["/"] = Dataset(
                    attrs={
                        "stac_discovery": {
                            "id": counter,
                            "properties": {
                                "product:type": "S02MSIL1C",
                                "eo:cloud_cover": 0.0,
                                "eo:snow_cover": 0.0,
                                "processing:version": "04.00",
                                "start_datetime": "2021-01-01T01:01:01",
                                "end_datetime": "2021-01-01T01:01:01",
                                "platform": "S2B",
                                "sat:relative_orbit": 128,
                                "product:timeliness_category": "NR",
                                "product:timeliness": "PT3H",
                            },
                        },
                        "test_string_ok": "abc",
                        "test_list_ok": ["abc", "def"],
                        "differents_values": {
                            "test_int": 3,
                            "test_float": 3.5,
                            "test_string_nok": "def",
                            "test_date": "2025-02-19T14:04:05.890464Z",
                            "test_list_ko1": ["abc", "def", "ghi"],
                            "test_list_ko2": ["def", "def"],
                            "dict_other": {"dict_str": "xyz", "dict_list": [{"dict_list_str": "test1"}]},
                            "proj:bbox": [399960.0, 6890220.0, 509760.0, 7000020.0],
                            "bbox": [-3.992785161066348, 61.2332991784862, -4.923979616288271, 62.22255891578805],
                            "coordinates": [
                                [
                                    [counter % 2, 0],
                                    [counter % 2, 2],
                                    [counter % 2 + 1, 2],
                                    [counter % 2 + 1, 0],
                                    [counter % 2, 0],
                                ],
                            ],
                        },
                        "no_corres_2": "test",
                    },
                )

            dt = DataTree.from_dict(datatree_dict)
            dt.to_zarr(path / f"tile_{counter:02d}.zarr")
    return str(path)


@pytest.fixture
def input_dir_to_update(tmp_path: Path) -> str:
    length = 1_200
    y_shift = 0
    path = tmp_path / "tiles"
    path.mkdir()
    counter = 0
    for x_shift in [0, 1_050]:

        counter += 1
        datatree_dict = {}

        # Geometry
        da = create_tile_sun_angles(
            x_length=length,
            y_length=length,
            x_shift=x_shift,
            y_shift=y_shift,
            resolution=50,
            value=np.array(counter, dtype="uint8"),
            name="sun_angles",
        )
        ds = da.to_dataset()
        datatree_dict["/conditions/geometry"] = ds

        for resolution, band in ((10, "b02"), (20, "b05"), (60, "b01")):
            da = create_tile_da(
                x_length=length,
                y_length=length,
                x_shift=x_shift,
                y_shift=y_shift,
                resolution=resolution,
                value=float(counter),
                name="foo",
            )
            ds = da.to_dataset()

            datatree_dict[f"/measurements/reflectance/r{resolution}m/{band}"] = ds

        da = create_tile_l1c_classification_mask(
            x_length=length,
            y_length=length,
            x_shift=x_shift,
            y_shift=y_shift,
            resolution=10,
            value=counter,
            name="b00",
        )
        ds = da.to_dataset()
        datatree_dict["/conditions/mask/l1c_classification/r60m"] = ds

        datasets = []
        for resolution in (10, 20, 60):
            da = create_tile_da(
                x_length=length,
                y_length=length,
                x_shift=x_shift,
                y_shift=y_shift,
                resolution=resolution,
                value=np.array(counter, dtype="uint8"),
                name=f"foo_{resolution}m",
            )
            da = da.rename({dim: dim.replace(dim, f"{dim}{resolution}m") for dim in da.dims if isinstance(dim, str)})
            datasets.append(da.to_dataset())
        ds = xr.merge(datasets)
        datatree_dict["/quality"] = ds

        if counter % 2:
            datatree_dict["/"] = Dataset(
                attrs={
                    "stac_discovery": {
                        "id": counter,
                        "properties": {
                            "product:type": "S02MSIL1C",
                            "eo:cloud_cover": 0.0,
                            "eo:snow_cover": 0.0,
                            "eopf:image_size": ["fake"],
                            "processing:version": "04.00",
                            "start_datetime": "2021-01-01T01:01:01",
                            "end_datetime": "2021-01-01T01:01:01",
                            "platform": "S2B",
                            "sat:relative_orbit": 128,
                            "product:timeliness_category": "NR",
                            "product:timeliness": "PT3H",
                        },
                    },
                    "other_metadata": {
                        "mean_sun_azimuth_angle_in_deg_for_all_bands_all_detectors": 0.0,
                        "mean_sun_zenith_angle_in_deg_for_all_bands_all_detectors": 0.0,
                    },
                },
            )
        else:
            datatree_dict["/"] = Dataset(
                attrs={
                    "stac_discovery": {
                        "id": counter,
                        "properties": {
                            "product:type": "S02MSIL1C",
                            "eo:cloud_cover": 100.0,
                            "eo:snow_cover": 100.0,
                            "eopf:image_size": ["fake_"],
                            "processing:version": "04.00",
                            "start_datetime": "2021-01-01T01:01:01",
                            "end_datetime": "2021-01-01T01:01:01",
                            "platform": "S2B",
                            "sat:relative_orbit": 128,
                            "product:timeliness_category": "NR",
                            "product:timeliness": "PT3H",
                        },
                    },
                    "other_metadata": {
                        "mean_sun_azimuth_angle_in_deg_for_all_bands_all_detectors": 1.0,
                        "mean_sun_zenith_angle_in_deg_for_all_bands_all_detectors": 1.0,
                    },
                },
            )

        dt = DataTree.from_dict(datatree_dict)
        dt.to_zarr(path / f"tile_{counter:02d}.zarr")
    return str(path)


@pytest.fixture
def dt(monkeypatch: MonkeyPatch, input_dir: str) -> DataTree:
    monkeypatch.setitem(OPEN_DATASET_KWARGS, "drop_variables", ["bar"])
    return open_and_combine_tiles(input_dir, update_mode=False)


@pytest.fixture
def dt_to_update(monkeypatch: MonkeyPatch, input_dir_to_update: str) -> DataTree:
    monkeypatch.setitem(OPEN_DATASET_KWARGS, "drop_variables", ["bar"])
    return open_and_combine_tiles(input_dir_to_update, update_mode=True)


@pytest.mark.unit
def test_merge_attrs_updated(dt_to_update: DataTree) -> None:
    stac_discovery = dt_to_update["/"].attrs["stac_discovery"]
    assert stac_discovery["id"] == "S02MSIL1C_20210101T010101_0000_B128_TD59"
    assert stac_discovery["properties"]["eo:cloud_cover"] == 31.858407079646017
    assert stac_discovery["properties"]["eo:snow_cover"] == 17.699115044247787
    other_metadata = dt_to_update["/"].attrs["other_metadata"]
    assert other_metadata["mean_sun_zenith_angle_in_deg_for_all_bands_all_detectors"] == 1.5
    assert other_metadata["mean_sun_azimuth_angle_in_deg_for_all_bands_all_detectors"] == 3.0
    assert stac_discovery["properties"]["eopf:image_size"] == [
        {"columns": 226, "name": "bands 02, 03, 04, 08", "rows": 121, "start_offset": 0, "track_offset": 0},
        {"columns": 114, "name": "bands 05, 06, 07, 8A, 11, 12", "rows": 121, "start_offset": 0, "track_offset": 0},
        {"columns": 38, "name": "bands 01, 09, 10", "rows": 121, "start_offset": 0, "track_offset": 0},
    ]


@pytest.mark.unit
def test_merge_geometry(dt: DataTree) -> None:
    ds = dt["/conditions/geometry"]
    assert set(ds.variables) == {"x", "foo", "y", "foo_dim"}

    da = ds["foo"]
    assert da.sizes == {"foo_dim": 2, "x": 46, "y": 43}

    x_index = 23
    y_index = 21
    assert (da[:, :x_index, :y_index] == 1).all()
    assert (da[:, :x_index, y_index:] == 2).all()
    assert (da[:, x_index:, :y_index] == 3).all()
    assert (da[:, x_index:, y_index:] == 4).all()


@pytest.mark.unit
def test_merge_missing_tile(monkeypatch: MonkeyPatch, input_dir: str) -> None:
    monkeypatch.setitem(OPEN_DATASET_KWARGS, "drop_variables", ["bar"])
    shutil.rmtree(f"{input_dir}/tile_01.zarr")
    with pytest.raises(ValueError, match="hypercube"):
        open_and_combine_tiles(input_dir, update_mode=False)

    dt = open_and_combine_tiles(input_dir, allow_missing_tiles=True, update_mode=False)
    da = dt["/conditions/geometry"]["foo"]

    x_index = 23
    y_index = 21
    assert (da[:, :x_index, :y_index] == 0).all()
    assert (da[:, :x_index, y_index:] == 2).all()
    assert (da[:, x_index:, :y_index] == 3).all()
    assert (da[:, x_index:, y_index:] == 4).all()


@pytest.mark.unit
@pytest.mark.parametrize("resolution", (1, 2, 6))
def test_merge_resolution_separated(dt: DataTree, resolution: int) -> None:
    da = dt[f"/measurements/reflectance/r{resolution}m"]["foo"]

    x_index = da.sizes["x"] // 2
    y_index = da.sizes["y"] // 2
    assert (da[:x_index, :y_index] == 1).all()
    assert (da[:x_index, y_index:] == 2).all()
    assert (da[x_index:, :y_index] == 3).all()
    assert (da[x_index:, y_index:] == 4).all()

    assert (da["x"].diff("x") == resolution).all()
    assert (da["y"].diff("y") == resolution).all()


@pytest.mark.unit
@pytest.mark.parametrize("resolution", (1, 2, 6))
def test_merge_resolution_mixed(dt: DataTree, resolution: int) -> None:
    ds = dt["/quality"]
    assert ds.sizes == {"x_6m": 376, "y_6m": 351, "x_1m": 2251, "y_1m": 2101, "x_2m": 1126, "y_2m": 1051}

    da = ds[f"foo_{resolution}m"]
    x_dim = f"x_{resolution}m"
    y_dim = f"y_{resolution}m"
    x_index = da.sizes[x_dim] // 2
    y_index = da.sizes[y_dim] // 2
    assert (da[:x_index, :y_index] == 1).all()
    assert (da[:x_index, y_index:] == 2).all()
    assert (da[x_index:, :y_index] == 3).all()
    assert (da[x_index:, y_index:] == 4).all()

    assert (da[x_dim].diff(x_dim) == resolution).all()
    assert (da[y_dim].diff(y_dim) == resolution).all()


@pytest.mark.unit
def test_merge_attrs(dt: DataTree) -> None:
    assert dt["/"].attrs["test_string_ok"] == "abc"
    assert dt["/"].attrs["test_list_ok"] == ["abc", "def"]

    attrs_to_merge = dt["/"].attrs["differents_values"]
    assert attrs_to_merge["test_int"] == 2
    assert attrs_to_merge["test_float"] == 2.5
    assert attrs_to_merge["test_string_nok"] is None
    assert attrs_to_merge["test_date"] == "2025-02-19T13:04:05.890464Z"
    assert attrs_to_merge["test_list_ko1"] == []
    assert attrs_to_merge["test_list_ko2"] == []
    assert attrs_to_merge["dict_other"]["dict_str"] == "xyz"
    assert attrs_to_merge["dict_other"]["dict_list"][0]["dict_list_str"] == "test1"
    assert "dict_list_str_ko" not in attrs_to_merge["dict_other"]["dict_list"][0]
    assert attrs_to_merge["bbox"] == [-3.992785161066348, 61.2332991784862, -4.933827079364661, 62.3653862905382]
    assert attrs_to_merge["proj:bbox"] == [399960.0, 6790200.0, 509760.0, 7000020.0]

    coordinates = [[[1.0, 2.0], [2.0, 2.0], [2.0, 0.0], [1.0, 0.0], [0.0, 0.0], [0.0, 2.0], [1.0, 2.0]]]
    assert attrs_to_merge["coordinates"] == coordinates

    assert "no_correspondance_1" not in dt["/"].attrs
    assert "no_correspondance_2" not in dt["/"].attrs


@pytest.mark.unit
def test_merge_sanity_check(monkeypatch: MonkeyPatch, input_dir: str, dt: DataTree) -> None:

    with pytest.raises(Exception):
        sanity_check(input_dir, dt)

    # list all keys with differents values
    inconsistent_attrs = ["differents_values", "stac_discovery", "no_corres_1", "no_corres_2", "timestamp"]
    monkeypatch.setattr(merge, "INCONSISTENT_ATTRS", inconsistent_attrs)
    sanity_check(input_dir, dt)


@pytest.mark.unit
def test_merge_to_zarr(tmp_path: Path, dt: DataTree) -> None:
    path = tmp_path / "combined.zarr"
    dt.to_zarr(path)
    open_datatree(path, engine="zarr")
