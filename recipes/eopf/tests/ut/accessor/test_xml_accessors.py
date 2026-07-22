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
import os

import numpy
import pytest
from xarray import DataArray

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")

from eopf.accessor import (
    XMLAnglesAccessor,
    XMLMultipleFilesAccessor,
)
from eopf.accessor.conveniences import open_accessor
from eopf.common.file_utils import AnyPath
from eopf.exceptions.errors import AccessorNotOpenError

"""
xml angles accesor tests
"""


@pytest.fixture
def mapping(request) -> str:
    return request.getfixturevalue(request.param)


@pytest.mark.unit
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
@pytest.mark.parametrize(
    "array_size, expected_data, xpath, is_group, is_var",
    [
        (
            (23, 23),
            numpy.array([numpy.array(range(i * 23, (i + 1) * 23)) for i in range(23)]),
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Zenith/Values_List",
            False,
            False,
        ),
        (
            (23, 23),
            numpy.full((23, 23), 1.23, dtype=float),
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Azimuth/Values_List",
            False,
            False,
        ),
        (
            (2,),
            numpy.array(["b01", "b02"]),
            "to_bands(n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids)",
            False,
            False,
        ),
        (
            (2, 2, 23, 23),
            numpy.full((2, 2, 23, 23), 1.23, dtype=float),
            "n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids/Azimuth/Values_List",
            False,
            False,
        ),
    ],
)
def test_xml_angles_accessor(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
    mapping,
    array_size,
    expected_data,
    xpath,
    is_group: bool,
    is_var: bool,
):
    # Create and open xml angles accessor
    with open(mapping) as mapping_file:
        map_config = json.load(mapping_file)
    config = {"namespace": map_config["xml_mapping"]["namespace"]}
    xml_accessor = XMLAnglesAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "common", "MTD_TL.xml"))
    with pytest.raises(AccessorNotOpenError):
        xml_accessor.get_data(xpath)

    with open_accessor(xml_accessor, **config):
        with pytest.raises(KeyError):
            xml_accessor.get_data("truc/bidule")
        # verify data shapes / data name / data type
        result = xml_accessor.get_data(xpath)
        assert result.shape == array_size
        assert isinstance(result, DataArray)
        # create an xarray with a user defined value
        # check if all data from an xpath match with user defined xarray

        if isinstance(result.data, da.Array):
            assert numpy.all(xml_accessor.get_data(xpath).compute() == expected_data)
        else:
            if numpy.all(xml_accessor.get_data(xpath).data == expected_data) is False:
                breakpoint()
            assert numpy.all(xml_accessor.get_data(xpath).data == expected_data)


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.parametrize("mapping", ["S02MSIL1C_MAPPING"], indirect=["mapping"])
@pytest.mark.parametrize(
    "array_size, expected_data, xpath, is_group, is_var",
    [
        (
            (23, 23),
            numpy.array([numpy.array(range(i * 23, (i + 1) * 23)) for i in range(23)]),
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Zenith/Values_List",
            False,
            False,
        ),
        (
            (23, 23),
            numpy.full((23, 23), 1.23, dtype=float),
            "n1:Geometric_Info/Tile_Angles/Sun_Angles_Grid/Azimuth/Values_List",
            False,
            False,
        ),
        (
            (2,),
            numpy.array(["b01", "b02"]),
            "to_bands(n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids)",
            False,
            False,
        ),
        (
            (2, 2, 23, 23),
            numpy.full((2, 2, 23, 23), 1.23, dtype=float),
            "n1:Geometric_Info/Tile_Angles/Viewing_Incidence_Angles_Grids/Azimuth/Values_List",
            False,
            False,
        ),
    ],
)
def test_xml_angles_accessor_s3(
    mapping, array_size, expected_data, xpath, is_group: bool, is_var: bool, s3_config_real, s3_test_data,
):
    # Create and open xml angles accessor
    with open(mapping) as mapping_file:
        map_config = json.load(mapping_file)
    config = {"namespace": map_config["xml_mapping"]["namespace"]}
    xml_accessor = XMLAnglesAccessor(
        AnyPath(
            f"{s3_test_data[0]}://{s3_test_data[1]}/embedbed/MTD_TL.xml",
            **dict(s3_config_real),
        ),
    )
    with pytest.raises(AccessorNotOpenError):
        xml_accessor.get_data(xpath)

    with xml_accessor.open(**config):
        with pytest.raises(KeyError):
            xml_accessor.get_data("truc/bidule")
        # verify data shapes / data name / data type
        result = xml_accessor.get_data(xpath)
        assert result.shape == array_size
        assert isinstance(result, DataArray)
        # create an xarray with a user defined value
        # check if all data from an xpath match with user defined xarray

        if isinstance(result.data, da.Array):
            assert numpy.all(xml_accessor.get_data(xpath).compute() == expected_data)
        else:
            assert numpy.all(xml_accessor.get_data(xpath).data == expected_data)


@pytest.mark.unit
@pytest.mark.parametrize(
    "xpath, source_order, target_type, result",
    [
        (
            "adsHeader/polarisation",
            ["hh", "hv", "vv", "vh"],
            {"name": "int32", "enumeration": {"HH": 0, "HV": 1, "VV": 2, "VH": 3}, "default_value": -1},
            [2, 2, 2, 3, 3, 3],
        ),
        (
            "adsHeader/startTime",
            ["hh", "hv", "vv", "vh"],
            {"name": "datetime64[us]", "default_value": 0},
            numpy.array(
                [
                    "2022-06-15T16:24:10.346655",
                    "2022-06-15T16:24:11.279878",
                    "2022-06-15T16:24:09.473044",
                    "2022-06-15T16:24:10.346655",
                    "2022-06-15T16:24:11.279878",
                    "2022-06-15T16:24:09.473044",
                ],
                dtype="datetime64[us]",
            ),
        ),
        (
            "adsHeader/startTime",
            ["hh", "hv", "vv", "vh"],
            {"name": "datetime64[us]", "default_value": 0},
            numpy.array(
                [
                    "2022-06-15T16:24:10.346655",
                    "2022-06-15T16:24:11.279878",
                    "2022-06-15T16:24:09.473044",
                    "2022-06-15T16:24:10.346655",
                    "2022-06-15T16:24:11.279878",
                    "2022-06-15T16:24:09.473044",
                ],
                dtype="datetime64[us]",
            ),
        ),
    ],
)
def test_xml_multi_files_accessor(EMBEDED_TEST_DATA_FOLDER_UNIT, xpath, source_order, target_type, result):
    accessor = XMLMultipleFilesAccessor(os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "xmlmultifiles", "s1*.xml"))
    with open_accessor(
        accessor,
        mode="r",
        source_order=source_order,
        target_type=target_type,
    ):
        with pytest.raises(NotImplementedError):
            accessor.write_attrs("", {})

        print(result)
        print(accessor.get_data(xpath).compute())
        assert numpy.array_equal(accessor.get_data(xpath).compute(), result)
