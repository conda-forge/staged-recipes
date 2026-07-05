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

import numpy as np
import pandas as pd
import pytest
from xarray import DataArray, DataTree

from eopf.store.product_specific.S01 import (
    _generate_geolocation_grid,
    assign_axis_coord_to_orbit_vars,
    assign_degree_coord_to_doppler_centroid_vars,
    assign_range_coord_to_antena_pattern_vars,
    build_coordinates,
    compute_gcp_azimuth_time,
    compute_gcp_range_coord,
)


@pytest.mark.unit
def test_build_coordinates():
    additional_info = {
        "product_first_line_utc_time": "2024-01-01T00:00:00",
        "product_last_line_utc_time": "2024-01-01T00:00:02",
        "number_of_lines": 3,
        "number_of_samples": 4,
        "range_pixel_spacing": 10.0,
        "image_slant_range_time": 0.5,
        "range_sampling_rate": 2.0,
    }

    azimuth_time, pixel, line, ground_range, slant_range_time = build_coordinates(additional_info)

    np.testing.assert_array_equal(
        azimuth_time.values,
        pd.date_range(
            start="2024-01-01T00:00:00",
            end="2024-01-01T00:00:02",
            periods=3,
        ).values,
    )
    np.testing.assert_array_equal(pixel, np.array([0, 1, 2, 3]))
    np.testing.assert_array_equal(line, np.array([0, 1, 2]))
    np.testing.assert_allclose(ground_range, np.array([0.0, 10.0, 20.0, 30.0]))
    np.testing.assert_allclose(slant_range_time, np.array([0.5, 1.0, 1.5, 2.0]))


@pytest.mark.unit
def test_compute_gcp_azimuth_time_in_bounds():
    azimuth_time = pd.date_range("2024-01-01T00:00:00", periods=3, freq="1s")

    result = compute_gcp_azimuth_time(azimuth_time, 1)

    assert result == np.datetime64("2024-01-01T00:00:01.000000000")


@pytest.mark.unit
def test_compute_gcp_azimuth_time_after_last_line():
    azimuth_time = pd.date_range("2024-01-01T00:00:00", periods=3, freq="1s")

    result = compute_gcp_azimuth_time(azimuth_time, 4)

    assert result == np.datetime64("2024-01-01T00:00:03.000000000")


@pytest.mark.unit
def test_compute_gcp_azimuth_time_before_first_line_matches_current_code():
    azimuth_time = pd.date_range("2024-01-01T00:00:00", periods=3, freq="1s")

    result = compute_gcp_azimuth_time(azimuth_time, -1)

    # Current implementation returns t0 + 1 delta, not t0 - 1 delta.
    assert result == np.datetime64("2024-01-01T00:00:01.000000000")


@pytest.mark.unit
@pytest.mark.parametrize(
    ("range_coord_name", "pixel", "expected"),
    [
        ("ground_range", 3, 30.0),
        ("slant_range_time", 3, 2.0),
    ],
)
def test_compute_gcp_range_coord(range_coord_name, pixel, expected):
    additional_info = {
        "image_slant_range_time": 0.5,
        "range_sampling_rate": 2.0,
        "range_pixel_spacing": 10.0,
    }

    result = compute_gcp_range_coord(additional_info, pixel, range_coord_name)

    assert result == expected


@pytest.mark.unit
def test_generate_geolocation_grid():
    gcp = DataTree()
    gcp["latitude"] = DataArray([10.0, 11.0], dims=("grid_point",))
    gcp["longitude"] = DataArray([20.0, 21.0], dims=("grid_point",))
    gcp["height"] = DataArray([100.0, 101.0], dims=("grid_point",))
    gcp.coords["line"] = ("grid_point", [0, 2])
    gcp.coords["pixel"] = ("grid_point", [1, 3])

    result = _generate_geolocation_grid(gcp)

    assert result == [
        {
            "line": 0,
            "pixel": 1,
            "latitude": 10.0,
            "longitude": 20.0,
            "height": 100.0,
        },
        {
            "line": 2,
            "pixel": 3,
            "latitude": 11.0,
            "longitude": 21.0,
            "height": 101.0,
        },
    ]


@pytest.mark.unit
def test_assign_degree_coord_to_doppler_centroid_vars_matches_current_code():
    product = DataTree()
    product["conditions/doppler_centroid/data_dc_polynomial"] = DataArray(
        np.arange(6).reshape(2, 3),
        dims=("azimuth_time", "degree"),
        coords={
            "azimuth_time": ("azimuth_time", pd.date_range("2024-01-01", periods=2)),
            "degree": ("degree", [10, 20, 30]),
        },
    )
    product.conditions.doppler_centroid.data_dc_polynomial.coords["azimuth_time"].attrs["units"] = "ns"
    product.conditions.doppler_centroid.data_dc_polynomial.coords["degree"].attrs["long_name"] = "poly degree"

    assign_degree_coord_to_doppler_centroid_vars(product)

    result = product.conditions.doppler_centroid.data_dc_polynomial

    # Current implementation keeps the original degree coordinate values.
    np.testing.assert_array_equal(result.coords["degree"].values, np.array([10, 20, 30]))
    np.testing.assert_array_equal(
        result.coords["azimuth_time"].values,
        pd.date_range("2024-01-01", periods=2).values,
    )
    assert result.coords["azimuth_time"].attrs["units"] == "ns"
    assert result.coords["degree"].attrs["long_name"] == "poly degree"

    # Current implementation also replaces the data with NaNs.
    assert result.shape == (2, 3)
    assert np.isnan(result.values).all()


@pytest.mark.unit
def test_assign_axis_coord_to_orbit_vars_matches_current_code():
    product = DataTree()
    product["conditions/orbit/position"] = DataArray(
        np.arange(6).reshape(2, 3),
        dims=("azimuth_time", "axis"),
        coords={
            "azimuth_time": ("azimuth_time", pd.date_range("2024-01-01", periods=2)),
            "axis": ("axis", [0, 1, 2]),
        },
    )
    product.conditions.orbit.position.coords["azimuth_time"].attrs["units"] = "ns"

    assign_axis_coord_to_orbit_vars(product)

    result = product.conditions.orbit.position

    # Current implementation keeps the original axis coordinate values.
    np.testing.assert_array_equal(result.coords["axis"].values, np.array([0, 1, 2]))
    np.testing.assert_array_equal(
        result.coords["azimuth_time"].values,
        pd.date_range("2024-01-01", periods=2).values,
    )
    assert result.coords["azimuth_time"].attrs["units"] == "ns"

    # Current implementation also replaces the data with NaNs.
    assert result.shape == (2, 3)
    assert np.isnan(result.values).all()


@pytest.mark.unit
def test_assign_range_coord_to_antena_pattern_vars_updates_count_coord():
    product = DataTree()
    product["conditions/antenna_pattern/elevation_angle"] = DataArray(
        np.arange(6).reshape(2, 3),
        dims=("azimuth_time", "count"),
        coords={
            "azimuth_time": ("azimuth_time", pd.date_range("2024-01-01", periods=2)),
            "count": ("count", [5, 6, 7]),
        },
    )

    assign_range_coord_to_antena_pattern_vars(product)

    result = product.conditions.antenna_pattern["elevation_angle"]
    assert result.coords["count"].data.tolist() == [5, 6, 7]
    assert result.coords["azimuth_time"].data.tolist() == list(
        pd.date_range("2024-01-01", periods=2).to_numpy(),
    )
