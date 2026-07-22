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

import numpy as np
import pytest
from numpy import testing

from eopf.accessor import EOGribAccessor
from eopf.accessor.conveniences import open_accessor
from eopf.common.file_utils import AnyPath

EXPECTED_GRIB_MSL_ATTR = {
    "GRIB_paramId": 151,
    "GRIB_dataType": "fc",
    "GRIB_numberOfPoints": 81,
    "GRIB_typeOfLevel": "surface",
    "GRIB_stepUnits": 1,
    "GRIB_stepType": "instant",
    "GRIB_gridType": "regular_ll",
    "GRIB_uvRelativeToGrid": 0,
    "GRIB_NV": 0,
    "GRIB_Nx": 9,
    "GRIB_Ny": 9,
    "GRIB_cfName": "air_pressure_at_mean_sea_level",
    "GRIB_cfVarName": "msl",
    "GRIB_gridDefinitionDescription": "Latitude/Longitude Grid",
    "GRIB_iDirectionIncrementInDegrees": 0.126,
    "GRIB_iScansNegatively": 0,
    "GRIB_jDirectionIncrementInDegrees": 0.123,
    "GRIB_jPointsAreConsecutive": 0,
    "GRIB_jScansPositively": 0,
    "GRIB_latitudeOfFirstGridPointInDegrees": -9.042,
    "GRIB_latitudeOfLastGridPointInDegrees": -10.027,
    "GRIB_longitudeOfFirstGridPointInDegrees": 160.819,
    "GRIB_longitudeOfLastGridPointInDegrees": 161.826,
    "GRIB_missingValue": np.finfo(np.float32).max,
    "GRIB_name": "Mean sea level pressure",
    "GRIB_shortName": "msl",
    "GRIB_totalNumber": 0,
    "GRIB_units": "Pa",
    "long_name": "Mean sea level pressure",
    "units": "Pa",
    "standard_name": "air_pressure_at_mean_sea_level",
}

EXPECTED_GRIB_LON_ATTR = {
    "units": "degrees_east",
    "standard_name": "longitude",
    "long_name": "longitude",
}
EXPECTED_GRIB_LAT_ATTR = {
    "units": "degrees_north",
    "standard_name": "latitude",
    "long_name": "latitude",
    "stored_direction": "decreasing",
}


@pytest.mark.unit
@pytest.mark.parametrize(
    "eo_path, shape, attrs, sampled_values",
    [
        ("msl", (9, 9), EXPECTED_GRIB_MSL_ATTR, {(4, 4): 100971.8125}),
        ("coordinates/longitude", (9,), EXPECTED_GRIB_LON_ATTR, {(4,): 161.3225}),
        ("coordinates/latitude", (9,), EXPECTED_GRIB_LAT_ATTR, {(4,): -9.534}),
    ],
)
def test_grib_store_get_item(
        EMBEDED_TEST_DATA_FOLDER_UNIT: str,
    eo_path: str,
    shape: tuple[int, ...],
    attrs: dict[str, Any],
    sampled_values: dict[tuple[int, ...], float],
):
    filein = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "grib", "AUX_ECMWFT.grib")
    _grib_store_get_item(attrs, eo_path, filein, sampled_values, shape)


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize(
    "eo_path, shape, attrs, sampled_values",
    [
        ("msl", (9, 9), EXPECTED_GRIB_MSL_ATTR, {(4, 4): 100971.8125}),
        ("coordinates/longitude", (9,), EXPECTED_GRIB_LON_ATTR, {(4,): 161.3225}),
        ("coordinates/latitude", (9,), EXPECTED_GRIB_LAT_ATTR, {(4,): -9.534}),
    ],
)
def test_grib_store_get_item_s3(
    eo_path: str,
    shape: tuple[int, ...],
    attrs: dict[str, Any],
    sampled_values: dict[tuple[int, ...], float],
    s3_test_data,
    s3_config_real,
):
    filein = AnyPath(f"{s3_test_data[0]}://{s3_test_data[1]}/embedbed/AUX_ECMWFT.grib", **dict(s3_config_real))
    _grib_store_get_item(attrs, eo_path, filein, sampled_values, shape)


def _grib_store_get_item(attrs, eo_path, filein, sampled_values, shape):
    grib_store = EOGribAccessor(filein)
    with open_accessor(grib_store, indexpath=""):
        assert grib_store.get_data(eo_path).shape == shape
        print(
            dict(
                (key, value.strip() if isinstance(value, str) else value)
                for key, value in grib_store.get_data(eo_path).attrs.items()
            ),
        )
        print(attrs)
        assert (
            dict(
                (key, value.strip() if isinstance(value, str) else value)
                for key, value in grib_store.get_data(eo_path).attrs.items()
            )
            == attrs
        )
        for key, value in sampled_values.items():
            testing.assert_allclose(grib_store.get_data(eo_path).to_numpy()[key], value)
            testing.assert_allclose(grib_store.get_data(eo_path).to_numpy()[key], value)


@pytest.mark.unit
def test_grib_exceptions(EMBEDED_TEST_DATA_FOLDER_UNIT: str):
    filein = os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "grib", "AUX_ECMWFT.grib")
    _grib_exceptions(filein)


@pytest.mark.unit
@pytest.mark.real_s3
def test_grib_exceptions_s3(s3_test_data, s3_config_real):
    filein = AnyPath(f"{s3_test_data[0]}://{s3_test_data[1]}/embedbed/AUX_ECMWFT.grib", **dict(s3_config_real))
    _grib_exceptions(filein)


def _grib_exceptions(filein):
    grib_store = EOGribAccessor(filein)
    with open_accessor(grib_store, indexpath=""):
        with pytest.raises(AttributeError):
            set(grib_store.iter("test"))
        with pytest.raises(AttributeError):
            set(grib_store.iter("coordinates/test"))
        with pytest.raises(TypeError):
            grib_store["test"]
        with pytest.raises(TypeError):
            grib_store["coordinates/test"]
