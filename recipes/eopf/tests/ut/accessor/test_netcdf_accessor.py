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

import pytest
from xarray import DataArray, Dataset

from eopf.accessor.netcdf_accessors import (
    EONetCDFAccessor,
    EONetCDFDAttrAccessor,
    EONetCDFDimensionAccessor,
    EONetCDFMetadataAccessor,
)
from eopf.common.file_utils import AnyPath
from eopf.exceptions import AccessorNotOpenError
from eopf.exceptions.errors import (
    AccessorError,
    AccessorInvalidRequestError,
    MissingArgumentError,
)

NETCDF_CARTESIAN_AN = "S3B_SL_1_RBT____20230824T091058_cartesian_an.nc"
NETCDF_CARTESIAN_IN = "S3B_SL_1_RBT____20230824T091058_cartesian_in.nc"
NETCDF_OCN = "s1a-wv2-ocn-vv-20240926t080654-20240926t080657-055833-06d2b0-040.nc"


@pytest.fixture
def netcdf_data_folder(EMBEDED_TEST_DATA_FOLDER_UNIT: str) -> str:
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "accessor", "netcdf")


@pytest.fixture
def cartesian_an_path(netcdf_data_folder: str) -> str:
    return os.path.join(netcdf_data_folder, NETCDF_CARTESIAN_AN)


@pytest.fixture
def cartesian_in_path(netcdf_data_folder: str) -> str:
    return os.path.join(netcdf_data_folder, NETCDF_CARTESIAN_IN)


@pytest.fixture
def ocn_path(netcdf_data_folder: str) -> str:
    return os.path.join(netcdf_data_folder, NETCDF_OCN)


@pytest.fixture
def metadata_mapping() -> dict[str, str]:
    return {
        "title": "Text('Sentinel-1 OCN OSW Product')",
        "mission_phase": "missionPhase",
        "polarisation": "polarisation",
        "algorithm_version": "oswAlgorithmVersion",
        "gmf": "gmf",
        "polarisation_ratio": "polarisationRatio",
        "processing_start_time": "processingStartTime",
        "processing_center": "processingCenter",
        "clm_source": "clmSource",
        "bathymetry_source": "bathySource",
        "wind_source": "windSource",
        "statevector_utc": "statevectorUtc",
        "statevector_pos": "statevectorPos",
        "statevector_vel": "statevectorVel",
        "statevector_acc": "statevectorAcc",
        "ground_velocity": "groundVelocity",
        "prf": "prf",
        "radar_frequency": "radarFrequency",
        "radar_sampling_freq": "raSamplingFreq",
        "azimuth_sampling_freq": "azSamplingFreq",
        "noise_correction": "oswNoiseCorrection",
        "l2rp_version": "Text(Product prototype)",
        "osw_status": "oswStatus",
        "eopf_category": "Text(eoproduct)",
    }


"""
NetCDFAccessor
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "key, point, value, attrs",
    [
        (
            "x_an",
            (0, 0),
            -1000000.0,
            {"long_name": "Geolocated x (across track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "x_an",
            (500, 500),
            748094.0,
            {"long_name": "Geolocated x (across track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "y_an",
            (0, 0),
            -5000000.0,
            {"long_name": "Geolocated y (along track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "y_an",
            (500, 500),
            9982876.0,
            {"long_name": "Geolocated y (along track) coordinate of detector FOV centre", "units": "m"},
        ),
    ],
)
def test_netcdf_accessor_reads_values_and_attrs(
        cartesian_an_path: str,
        key: str,
        point: tuple[int, int],
        value: float,
        attrs: dict[str, Any],
) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)
    netcdf_accessor.open()

    try:
        data = netcdf_accessor.get_data(key)
        assert isinstance(data, DataArray)

        for attr_key, attr_value in attrs.items():
            assert attr_key in data.attrs
            assert data.attrs[attr_key] == attr_value

        computed = data.compute()
        assert computed[point[0], point[1]] == value

        assert EONetCDFAccessor.guess_can_read(cartesian_an_path)
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_accessor_root_returns_dataset(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)
    netcdf_accessor.open()

    try:
        root = netcdf_accessor.get_data("")
        assert isinstance(root, Dataset)
        assert "x_an" in root.data_vars
        assert "y_an" in root.data_vars
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_accessor_slash_root_returns_dataset(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)
    netcdf_accessor.open()

    try:
        root = netcdf_accessor.get_data("/")
        assert isinstance(root, Dataset)
        assert "x_an" in root.data_vars
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_accessor_missing_key_raises_key_error(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)
    netcdf_accessor.open()

    try:
        with pytest.raises(KeyError):
            netcdf_accessor.get_data("machin")
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_accessor_not_open_errors(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.get_data("x_an")

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_accessor_after_close_raises(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFAccessor(cartesian_an_path)
    netcdf_accessor.open()
    netcdf_accessor.close()

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.get_data("x_an")


@pytest.mark.unit
def test_netcdf_accessor_open_missing_file_raises() -> None:
    netcdf_accessor = EONetCDFAccessor("/tmp/does_not_exist_123456.nc")

    with pytest.raises(FileNotFoundError):
        netcdf_accessor.open()


@pytest.mark.unit
def test_netcdf_accessor_write_mode_not_supported() -> None:
    netcdf_accessor = EONetCDFAccessor("s3://machin.nc")

    with pytest.raises(AccessorInvalidRequestError):
        netcdf_accessor.open(mode="w")


@pytest.mark.real_s3
@pytest.mark.parametrize(
    "key, point, value, attrs",
    [
        (
            "x_an",
            (0, 0),
            -1000000.0,
            {"long_name": "Geolocated x (across track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "x_an",
            (500, 500),
            748094.0,
            {"long_name": "Geolocated x (across track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "y_an",
            (0, 0),
            -5000000.0,
            {"long_name": "Geolocated y (along track) coordinate of detector FOV centre", "units": "m"},
        ),
        (
            "y_an",
            (500, 500),
            9982876.0,
            {"long_name": "Geolocated y (along track) coordinate of detector FOV centre", "units": "m"},
        ),
    ],
)
def test_netcdf_accessor_s3(
        key: str,
        point: tuple[int, int],
        value: float,
        attrs: dict[str, Any],
        s3_test_data,
        s3_config_real,
) -> None:
    in_path = AnyPath(
        f"{s3_test_data[0]}://{s3_test_data[1]}/embedbed/{NETCDF_CARTESIAN_AN}",
        **dict(s3_config_real),
    )
    assert in_path.exists()

    netcdf_accessor = EONetCDFAccessor(in_path)
    netcdf_accessor.open()

    try:
        data = netcdf_accessor.get_data(key)
        assert isinstance(data, DataArray)

        for attr_key, attr_value in attrs.items():
            assert attr_key in data.attrs
            assert data.attrs[attr_key] == attr_value

        computed = data.compute()
        assert computed[point[0], point[1]] == value

        assert EONetCDFAccessor.guess_can_read(in_path)
    finally:
        netcdf_accessor.close()


"""
NetCDFDimensionAccessor
"""


@pytest.mark.unit
def test_netcdf_dimension_accessor_reads_dimension(cartesian_in_path: str) -> None:
    netcdf_accessor = EONetCDFDimensionAccessor(cartesian_in_path)
    netcdf_accessor.open()

    try:
        val = netcdf_accessor.get_data("orphan_pixels").compute()
        assert isinstance(val, DataArray)
        assert val[0] == 0
        assert not EONetCDFDimensionAccessor.guess_can_read(cartesian_in_path)
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_dimension_accessor_missing_dimension_raises(cartesian_in_path: str) -> None:
    netcdf_accessor = EONetCDFDimensionAccessor(cartesian_in_path)
    netcdf_accessor.open()

    try:
        with pytest.raises(KeyError):
            netcdf_accessor.get_data("machin")
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_dimension_accessor_not_open_errors(cartesian_an_path: str) -> None:
    netcdf_accessor = EONetCDFDimensionAccessor(cartesian_an_path)

    with pytest.raises(AccessorInvalidRequestError):
        netcdf_accessor.open(mode="w")

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.close()

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.get_data("orphan_pixels")


"""
EONetCDFDAttrAccessor
"""


@pytest.mark.unit
@pytest.mark.parametrize(
    "mapping, values",
    [
        (
            {
                "voltage_gain_applied_to_detector_signal_s1_an": (
                        "to_float(S3B_SL_1_RBT____20230824T091058_S1_quality_an.nc:S1_FEE_gain_an)"
                ),
                "voltage_gain_applied_to_detector_signal_s1_an_str": (
                        "S3B_SL_1_RBT____20230824T091058_S1_quality_an.nc:S1_FEE_gain_an"
                ),
                "not_found": "S3B_SL_1_RBT____20230824T091058_S1_quality_an.nc:S1_FEE_an",
            },
            {
                "voltage_gain_applied_to_detector_signal_s1_an": 1.0,
                "voltage_gain_applied_to_detector_signal_s1_an_str": 1.0,
            },
        ),
    ],
)
def test_netcdf_to_attr_accessor(
        netcdf_data_folder: str,
        mapping: dict[str, Any],
        values: dict[str, Any],
) -> None:
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)
    netcdf_accessor.open(mapping=mapping)

    try:
        val = netcdf_accessor.get_data("")
        assert isinstance(val, DataArray)

        for key, expected in values.items():
            assert key in val.attrs
            assert val.attrs[key] == expected

        assert "not_found" not in val.attrs
        assert not EONetCDFDAttrAccessor.guess_can_read(netcdf_data_folder)
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_to_attr_accessor_nested_mapping(netcdf_data_folder: str) -> None:
    mapping = {
        "level1": {
            "gain": "to_float(S3B_SL_1_RBT____20230824T091058_S1_quality_an.nc:S1_FEE_gain_an)",
        },
    }

    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)
    netcdf_accessor.open(mapping=mapping)

    try:
        val = netcdf_accessor.get_data("")
        assert isinstance(val, DataArray)
        assert val.attrs["level1"]["gain"] == 1.0
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_to_attr_accessor_missing_mapping_raises(netcdf_data_folder: str) -> None:
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)

    with pytest.raises(MissingArgumentError):
        netcdf_accessor.open()


@pytest.mark.unit
def test_netcdf_to_attr_accessor_write_mode_not_supported(netcdf_data_folder: str) -> None:
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)

    with pytest.raises(AccessorInvalidRequestError):
        netcdf_accessor.open(mode="w", mapping={})


@pytest.mark.unit
def test_netcdf_to_attr_accessor_not_open_errors(netcdf_data_folder: str) -> None:
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.get_data("")

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_to_attr_accessor_bad_reference_raises_accessor_error(
        netcdf_data_folder: str,
) -> None:
    mapping = {
        "broken": "missing_file.nc:missing_var",
    }
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)
    netcdf_accessor.open(mapping=mapping)

    try:
        with pytest.raises(AccessorError):
            netcdf_accessor.get_data("")
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_to_attr_accessor_non_netcdf_expression_is_ignored(
        netcdf_data_folder: str,
) -> None:
    mapping = {
        "broken": "not_a_valid_expression",
    }
    netcdf_accessor = EONetCDFDAttrAccessor(netcdf_data_folder)
    netcdf_accessor.open(mapping=mapping)

    try:
        data = netcdf_accessor.get_data("")
        assert isinstance(data, DataArray)
        assert "broken" not in data.attrs
    finally:
        netcdf_accessor.close()


"""
EONetCDFMetadataAccessor
"""


@pytest.mark.unit
def test_netcdf_metadata_accessor(ocn_path: str, metadata_mapping: dict[str, str]) -> None:
    netcdf_accessor = EONetCDFMetadataAccessor(ocn_path)
    netcdf_accessor.open(mapping=metadata_mapping)

    try:
        data = netcdf_accessor.get_data("")
        assert isinstance(data, DataArray)
        assert data.attrs

        assert data.attrs["processing_start_time"] == "2024-09-26T09:23:53.977516Z"
        assert data.attrs["prf"] == pytest.approx(1650.168040094962)
        assert data.attrs["title"] == "'Sentinel-1 OCN OSW Product'"
        assert data.attrs["eopf_category"] == "eoproduct"
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_metadata_accessor_returns_python_native_values(
        ocn_path: str,
        metadata_mapping: dict[str, str],
) -> None:
    netcdf_accessor = EONetCDFMetadataAccessor(ocn_path)
    netcdf_accessor.open(mapping=metadata_mapping)

    try:
        data = netcdf_accessor.get_data("")
        assert isinstance(data.attrs["prf"], float)
        assert isinstance(data.attrs["processing_start_time"], str)
    finally:
        netcdf_accessor.close()


@pytest.mark.unit
def test_netcdf_metadata_accessor_missing_mapping_raises(ocn_path: str) -> None:
    netcdf_accessor = EONetCDFMetadataAccessor(ocn_path)

    with pytest.raises(MissingArgumentError):
        netcdf_accessor.open()


@pytest.mark.unit
def test_netcdf_metadata_accessor_write_mode_not_supported(
        ocn_path: str,
        metadata_mapping: dict[str, str],
) -> None:
    netcdf_accessor = EONetCDFMetadataAccessor(ocn_path)

    with pytest.raises(NotImplementedError):
        netcdf_accessor.open(mode="w", mapping=metadata_mapping)


@pytest.mark.unit
def test_netcdf_metadata_accessor_not_open_errors(ocn_path: str) -> None:
    netcdf_accessor = EONetCDFMetadataAccessor(ocn_path)

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.get_data("")

    with pytest.raises(AccessorNotOpenError):
        netcdf_accessor.close()
