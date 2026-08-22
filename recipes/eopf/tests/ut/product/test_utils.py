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
import sys
from cmath import inf
from typing import Any, Mapping

import hypothesis.extra.numpy as xps
import hypothesis.extra.pytz as xptz
import hypothesis.strategies as st
import numpy as np
import pytest
from hypothesis import assume, given
from numpy import uint16
from xarray import DataArray

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")

from eopf.common.geometry_utils import bbox_block
from eopf.common.json_utils import (
    decode_all_attrs,
    decode_attr,
    encode_all_attrs,
    encode_attr,
)
from eopf.common.type_utils import convert_to_native_python_type, reverse_conv
from eopf.product.utils.dtree_transformers_utils import (
    transformation_astype,
    transformation_attributes,
    transformation_dimensions,
    transformation_expand_dims,
    transformation_pack_bits,
    transformation_rechunk,
    transformation_squeeze,
    transformation_sub_array,
    transformation_transpose,
)
from tests.ut.test_miscellaneous import numpy_value, value_with_type


@pytest.mark.unit
@pytest.mark.parametrize(
    "obj, result",
    [([0, 1, 2], [0, 1, 2]), ((1, 2, 3), (1, 2, 3))],
)
def test_convert_to_native(obj, result):
    assert convert_to_native_python_type(obj) == result


@pytest.mark.unit
@given(
    value_and_types=st.one_of(
        value_with_type(
            st.lists(elements=st.floats(allow_infinity=False, allow_nan=False), unique=True, min_size=10),
            float,
            list,
        ),
        value_with_type(st.lists(elements=st.integers(), unique=True, min_size=10), int, list),
        value_with_type(st.lists(elements=st.booleans(), unique=True, min_size=2), int, list),
        value_with_type(st.sets(elements=st.floats(allow_infinity=False, allow_nan=False), min_size=10), float, set),
        value_with_type(st.sets(elements=st.integers(), min_size=10), int, set),
        value_with_type(st.sets(elements=st.booleans(), min_size=2), int, set),
        value_with_type(st.dictionaries(st.text(), st.integers(), min_size=10), int, dict),
        value_with_type(st.dictionaries(st.text(), st.booleans(), min_size=10), int, dict),
        value_with_type(
            st.dictionaries(st.text(), st.floats(allow_infinity=False, allow_nan=False), min_size=10),
            float,
            dict,
        ),
        value_with_type(xps.arrays(xps.floating_dtypes(), 10, unique=True), float, list),
        value_with_type(xps.arrays(xps.integer_dtypes(), 10, unique=True), int, list),
        value_with_type(xps.arrays(xps.boolean_dtypes(), 10, unique=True), int, list),
    ),
)
def test_conv_sequences(value_and_types: tuple[Any, type, type]):
    values, type_, container_type = value_and_types
    assume(inf not in values)
    converted_list = convert_to_native_python_type(values)
    assert isinstance(converted_list, container_type)
    # Check if size of converted value doesn't change
    assert len(converted_list) == len(values)
    # Check if type of each item from converted value is correct
    if isinstance(converted_list, dict):
        iterator = converted_list.values()
        original = values.values()
    else:
        iterator = converted_list
        original = values
    for converted_value, value in zip(sorted(iterator), sorted(original)):
        assert isinstance(converted_value, type_)
        conv_value = convert_to_native_python_type(value)
        # check if converted values are the same or both are nan
        assert converted_value == conv_value or (converted_value != converted_value and conv_value != conv_value)


@pytest.mark.unit
@pytest.mark.parametrize("EPSILON", [0.1])
@given(value=numpy_value(xps.floating_dtypes(), allow_infinity=False, allow_nan=False))
def test_epsilon_on_fp_conv(value, EPSILON):
    converted_value = convert_to_native_python_type(value)
    assert value - converted_value < EPSILON
    assert converted_value - value < EPSILON


@pytest.mark.unit
@given(
    value_and_type=st.one_of(
        value_with_type(
            elements=numpy_value(xps.floating_dtypes(), allow_infinity=False, allow_nan=False),
            expected_type=float,
        ),
        value_with_type(
            elements=numpy_value(xps.integer_dtypes(), allow_infinity=False, allow_nan=False),
            expected_type=int,
        ),
        value_with_type(
            elements=st.datetimes(timezones=xptz.timezones()),
            expected_type=int,
        ),
    ),
)
def test_conv(value_and_type):
    value, expected_type = value_and_type
    converted_value = convert_to_native_python_type(value)
    assert isinstance(converted_value, expected_type)


@pytest.mark.unit
@pytest.mark.parametrize(
    "sysmax, maxint",
    [
        (np.int64(sys.maxsize), np.int64(9223372036854775807)),
    ],
)
def test_maxint_conv(sysmax, maxint):
    # Robustness
    assert convert_to_native_python_type(sysmax) == maxint


@pytest.mark.unit
@given(
    value_and_types=st.one_of(
        value_with_type(
            st.integers(min_value=np.iinfo("int64").min, max_value=np.iinfo("int64").max),
            int,
            xps.integer_dtypes(endianness="=", sizes=(64,)),
        ),
        value_with_type(
            st.integers(min_value=np.iinfo("int32").min, max_value=np.iinfo("int32").max),
            int,
            xps.integer_dtypes(endianness="=", sizes=(32,)),
        ),
        value_with_type(
            st.integers(min_value=np.iinfo("int16").min, max_value=np.iinfo("int16").max),
            int,
            xps.integer_dtypes(endianness="=", sizes=(16,)),
        ),
        value_with_type(
            st.integers(min_value=np.iinfo("int8").min, max_value=np.iinfo("int8").max),
            int,
            xps.integer_dtypes(endianness="=", sizes=(8,)),
        ),
        value_with_type(st.floats(width=16), float, xps.floating_dtypes(endianness="=", sizes=(16,))),
        value_with_type(st.floats(width=32), float, xps.floating_dtypes(endianness="=", sizes=(32,))),
        value_with_type(st.floats(width=64), float, xps.floating_dtypes(endianness="=", sizes=(64,))),
    ),
)
def test_reverse_conv(value_and_types):
    value, current_type, data_type = value_and_types
    # verify if the current data type is as expected (int or float)
    assert isinstance(value, current_type)
    # convert value to given data type (int64, int32, float64 etc .. )
    converted_value = reverse_conv(data_type, value)
    # check if conversion is performed according to given data (int -> np.int64, float -> np.float64)
    assert np.issubdtype(type(converted_value), data_type)
    # check if converted data type is changed and not match with old one
    assert type(converted_value) is not current_type


@pytest.mark.unit
@pytest.mark.parametrize(
    "data_type, obj, result",
    [
        (uint16, 0, 0),
    ],
)
def test_reverse_conv_bis(data_type: Any, obj: Any, result):
    assert reverse_conv(data_type, obj) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "attrs_map, result",
    [
        ({"truc": "machin"}, {"truc": "machin"}),
    ],
)
def test_decode_all_attrs(attrs_map: Mapping[str, Any], result):
    assert decode_all_attrs(attrs_map) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "attr, result",
    [
        ("machin", "machin"),
    ],
)
def test_decode_attr(attr: Any, result) -> Any:
    assert decode_attr(attr) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "attrs_map, data_type, result",
    [
        ({"truc": "machin"}, None, {"truc": "machin"}),
    ],
)
def test_encode_all_attrs(attrs_map: Mapping[str, Any], data_type: Any, result):
    assert encode_all_attrs(attrs_map) == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "attr, result",
    [
        ("machin", "machin"),
    ],
)
def test_encode_attr(attr: Any, result) -> Any:
    assert encode_attr(attr) == result


@pytest.mark.unit
def test_xarray_to_data_map_block():
    # TODO
    pass


@pytest.mark.unit
@pytest.mark.parametrize(
    "testdata_block_x,testdata_block_y",
    [(np.array([[5, 6, 7, 8], [6, 7, 8, 9], [7, 8, 9, 10]]), np.array([[9, 9, 8, 8], [7, 7, 6, 6], [5, 5, 4, 4]]))],
)
def test_bbox_block(testdata_block_x, testdata_block_y):
    block_id = (1, 2)
    region = [5.5, 7.5, 3.0, 4.0]
    chunksize = (3, 4)
    bbox = bbox_block(
        testdata_block_x,
        testdata_block_y,
        block_id=block_id,
        chunksize=chunksize,
        region=region,
        is_geographic=True,
    )
    assert bbox[0, 0, 0] == 9
    assert bbox[1, 0, 0] == 3
    assert bbox[2, 0, 0] == 11
    assert bbox[3, 0, 0] == 3


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis, dimensions",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 5)))), [0], ("x", "y", "z")),
    ],
)
def test_transformation_expand_dims(var, axis, dimensions):
    transformed = transformation_expand_dims(var, {"axis": axis, "dimensions": dimensions})
    assert transformed.dims == dimensions
    assert len(transformed.data.shape) == len(var.data.shape) + 1


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, dtypeout",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 1)))), "float64"),
    ],
)
def test_transformation_dtype(var, dtypeout):
    transformed = transformation_astype(var, dtypeout)
    assert transformed.data.dtype == np.dtype(dtypeout)


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, outchunk, expected",
    [
        (
            DataArray(name="test", data=da.from_array(np.zeros((50, 20)), chunks=(5, 5))),
            {"dim_0": 1, "dim_1": 1},
            (
                (
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                    1,
                ),
                (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
            ),
        ),
    ],
)
def test_transformation_rechunk(var, outchunk, expected):
    transformed = transformation_rechunk(var, outchunk)
    print(transformed.chunks)
    assert transformed.chunks == expected


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis, dimensions",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 1)))), [1], ("x",)),
    ],
)
def test_transformation_squeeze(var, axis, dimensions):
    transformed = transformation_squeeze(var, {"axis": axis, "dimensions": dimensions})
    assert transformed.dims == dimensions
    assert len(transformed.data.shape) == len(var.data.shape) - 1


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis, new_shape",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((1, 5)))), None, (5, 1)),
    ],
)
def test_transformation_transpose(var, axis, new_shape):
    transformed = transformation_transpose(var, axis)
    assert transformed.shape == new_shape


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, dimensions",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 5)))), ("x", "y")),
    ],
)
def test_transformation_dimensions(var, dimensions):
    transformed = transformation_dimensions(var, dimensions)
    assert transformed.dims == dimensions


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, attrs",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 5)))), {"units": "meters"}),
    ],
)
def test_transformation_attributes(var, attrs):
    transformed = transformation_attributes(var, attrs)
    for key, values in attrs.items():
        assert transformed.attrs[key] == values


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, selector, result",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 5)))), {"dim_0": 0}, ("dim_1",)),
    ],
)
def test_transformation_sub_array(var, selector, result):
    transformed = transformation_sub_array(var, selector)
    assert transformed.dims == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis",
    [
        (DataArray(name="test", data=da.from_array(np.zeros((5, 5), dtype=bool))), "dim_1"),
    ],
)
def test_transformation_pack_bits(var, axis):
    print(var.dims)
    transformed = transformation_pack_bits(var, axis)
    assert len(transformed.data.shape) == len(var.data.shape) - 1
