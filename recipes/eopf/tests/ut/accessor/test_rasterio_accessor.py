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
import os
from typing import Any
from unittest.mock import patch

import numpy as np
import pyproj
import pytest
import xarray
from rioxarray.crs import crs_from_user_input
from rioxarray.raster_array import RasterArray
from xarray import DataArray, Dataset

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")

from eopf.accessor.conveniences import open_accessor
from eopf.accessor.rasterio import EOMultiSourceRasterIOAccessor, EORasterIOAccessor, EORasterIOAccessorToAttr
from eopf.common.file_utils import AnyPath
from eopf.exceptions.errors import (
    AccessorNotOpenError,
    MissingArgumentError,
)


@pytest.mark.unit
@pytest.mark.parametrize(
    "store_cls, format_file, params",
    [(EORasterIOAccessor, "tiff", {}), (EORasterIOAccessor, "jp2", {})],
)
def test_read_rasters_mock(store_cls: type[EORasterIOAccessor], format_file: str, params: dict[str, Any]):
    file_name = f"a_file.{format_file}"
    raster = store_cls(file_name)

    with patch("rioxarray.open_rasterio") as mock_function:
        data_val = [[1, 2, 3], [3, 4, 5], [6, 7, 8]]
        coord_a = [1, 2, 4]
        coord_b = [14, 5, 7]
        mock_function.return_value = xarray.DataArray(
            data_val,
            coords={
                "a": coord_a,
                "b": coord_b,
            },
        )

        with open_accessor(raster, mode="r", **params):
            value = raster.get_data("")
            print(value)
            assert isinstance(value, DataArray)
            assert np.array_equal(value, data_val)

            assert np.array_equal(value, data_val)

            assert np.array_equal(raster.get_data("coordinates")["a"], coord_a)
            assert np.array_equal(raster.get_data("coordinates/a"), coord_a)

            assert np.array_equal(raster.get_data("coordinates")["b"], coord_b)
            assert np.array_equal(raster.get_data("coordinates/b"), coord_b)

            not_existing_key = "not_existing_key"
            with pytest.raises(TypeError):
                raster[not_existing_key]

        for return_val in [xarray.Dataset(data_vars={"a": xarray.DataArray()}), [xarray.Dataset()]]:
            mock_function.return_value = return_val
            with open_accessor(raster, mode="r", **params):
                with pytest.raises(NotImplementedError):
                    raster.get_data("")

        with pytest.raises(AccessorNotOpenError):
            raster.close()


@pytest.mark.unit
@pytest.mark.parametrize(
    "format_file, params, shape",
    [
        # TODO : I don't hace a small enougth tiff for unit tests
        # ("tiff", {"source_order": ["hh", "hv", "vv", "vh"]}, (32, 5490, 5490)),
        ("jp2", {"source_order": ["hh", "hv", "vv", "vh"]}, (32, 5490, 5490)),
    ],
)
def test_read_multi_rasters(EMBEDED_TEST_DATA_FOLDER_UNIT: str, format_file: str, params: dict[str, Any], shape: Any):
    file_pattern = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "rasterio", f"*.{format_file}")
    raster = EOMultiSourceRasterIOAccessor(file_pattern)

    with pytest.raises(NotImplementedError):
        raster.open(mode="w")
    with pytest.raises(MissingArgumentError):
        raster.open()
    with raster.open(mode="r", **params):
        value = raster.get_data("")
        assert value.data.shape == shape

        with pytest.raises(NotImplementedError):
            raster.write_data("", DataArray())
        with pytest.raises(NotImplementedError):
            raster.write_attrs("", {})


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "format_file, params, shape",
    [
        # TODO : I don't hace a small enougth tiff for unit tests
        # ("tiff", {"source_order": ["hh", "hv", "vv", "vh"]}, (32, 5490, 5490)),
        ("jp2", {"source_order": ["hh", "hv", "vv", "vh"]}, (32, 5490, 5490)),
    ],
)
def test_read_multi_rasters_s3(format_file: str, params: dict[str, Any], shape: Any, s3_test_data, s3_config_real):
    file_pattern = AnyPath(
        f"{s3_test_data[0]}://{s3_test_data[1]}/embedbed/rasterio/*.{format_file}",
        **dict(s3_config_real),
    )
    print(s3_config_real)
    raster = EOMultiSourceRasterIOAccessor(file_pattern)

    with pytest.raises(NotImplementedError):
        raster.open(mode="w")
    with pytest.raises(MissingArgumentError):
        raster.open()
    with raster.open(mode="r", **params):
        value = raster.get_data("")
        assert value.data.shape == shape
        with pytest.raises(NotImplementedError):
            raster.write_data("", DataArray())
        with pytest.raises(NotImplementedError):
            raster.write_attrs("", {})


@pytest.mark.unit
def test_read_multi_rasters_errors():
    with pytest.raises(FileNotFoundError):
        EOMultiSourceRasterIOAccessor("truc")


@pytest.mark.unit
@pytest.mark.parametrize(
    "store_cls, format_file, params",
    [
        (EORasterIOAccessor, "tiff", {}),
        (EORasterIOAccessor, "jp2", {}),
    ],
)
def test_rasters(store_cls: type[EORasterIOAccessor], format_file: str, params: dict[str, Any]):
    file_name = f"a_file.{format_file}"
    raster = store_cls(file_name)
    with patch("rioxarray.open_rasterio") as mock_function:
        data_val = [[1, 2, 3], [3, 4, 5], [6, 7, 8]]
        coord_a = [1, 2, 4]
        coord_b = [14, 5, 7]
        mock_function.return_value = xarray.DataArray(
            data_val,
            coords={
                "a": coord_a,
                "b": coord_b,
            },
        )
        with raster.open(mode="r", **params):
            value = raster.get_data("")
            assert np.array_equal(value, data_val)

            assert isinstance(raster.get_data("value"), DataArray)
            assert np.array_equal(value, data_val)

            assert isinstance(raster.get_data("coordinates"), Dataset)

            assert isinstance(raster.get_data("coordinates")["a"], DataArray)
            assert np.array_equal(raster.get_data("coordinates")["a"], coord_a)
            assert np.array_equal(raster.get_data("coordinates/a"), coord_a)

            assert isinstance(raster.get_data("coordinates")["b"], DataArray)
            assert np.array_equal(raster.get_data("coordinates")["b"], coord_b)
            assert np.array_equal(raster.get_data("coordinates/b"), coord_b)

            not_existing_key = "not_existing_key"
            with pytest.raises(TypeError):
                raster[not_existing_key]

        for return_val in [xarray.Dataset(data_vars={"a": xarray.DataArray()}), [xarray.Dataset()]]:
            mock_function.return_value = return_val
            with raster.open(mode="r", **params):
                with pytest.raises(NotImplementedError):
                    raster.get_data("")
                with pytest.raises(AttributeError):
                    [i for i in raster.iter("")]
                with pytest.raises(AttributeError):
                    [i for i in raster.iter("not_implemeted")]

        with pytest.raises(AccessorNotOpenError):
            raster.close()


class DataArrayWithRio(xarray.DataArray):
    """Subclass that exposes a .rio attribute."""

    @property
    def rio(self):
        rio = RasterArray(self)
        rio._crs = crs_from_user_input(32633)
        return rio

@pytest.mark.unit
def test_rasterio_to_attr_accessor():
    mapping = {
        "properties": {
            "p1": "jp2metadata:bounds",
            "p2": "jp2metadata:epgs",
            "p3": "jp2metadata:transform",
            "p4": "jp2metadata:shape",
            "p5": "jp2metadata:crs_wkt",
        },
    }

    data_val = [[[1, 2, 3], [3, 4, 5], [6, 7, 8]]]
    coord_x = [1, 2, 3]
    coord_y = [2, 3, 4]
    array = DataArrayWithRio(
        data_val,
        coords={"band": [0], "x": coord_x, "y": coord_y, "spatial_ref": 1},
        dims=["band", "x", "y"],
    )
    crs = pyproj.CRS.from_epsg(4326)
    attrs = crs.to_cf()
    array = array.assign_coords(dict(spatial_ref=xarray.DataArray(0, attrs=attrs)))

    with patch("rioxarray.open_rasterio") as mock_function:
        mock_function.return_value = array

        accessor = EORasterIOAccessorToAttr("fakepath")
        accessor.open(mapping=mapping)
        eog = accessor.get_data("")

        assert eog.attrs == {
            "properties": {
                "p1": [0.5, 1.5, 3.5, 4.5],
                "p2": 32633,
                "p3": [1.0, 0.0, 0.5, 0.0, 1.0, 1.5, 0.0, 0.0, 1.0],
                "p4": (3, 3),
                "p5": attrs["crs_wkt"],
            },
        }
