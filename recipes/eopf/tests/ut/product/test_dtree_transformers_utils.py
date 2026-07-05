import sys
from cmath import inf
from typing import Any, Mapping

import hypothesis.extra.numpy as xps
import hypothesis.extra.pytz as xptz
import hypothesis.strategies as st
import numpy as np
import pytest
from hypothesis import assume, given
from xarray import DataArray

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")

from eopf.common.constants import (
    ADD_OFFSET,
    DTYPE,
    FILL_VALUE,
    SCALE_FACTOR,
    TARGET_DTYPE,
    VALID_MAX,
    VALID_MIN,
    XARRAY_FILL_VALUE,
)
from eopf.common.geometry_utils import bbox_block
from eopf.common.json_utils import (
    decode_all_attrs,
    decode_attr,
    encode_all_attrs,
    encode_attr,
)
from eopf.common.type_utils import convert_to_native_python_type, reverse_conv
from eopf.product.utils.dtree_transformers_utils import (
    transformation_apply_spacing,
    transformation_astype,
    transformation_astype_datetime64,
    transformation_attributes,
    transformation_dimensions,
    transformation_dopplerTime,
    transformation_expand_dims,
    transformation_mask_and_scale_attributes,
    transformation_pack_bits,
    transformation_rechunk,
    transformation_squeeze,
    transformation_sub_array,
    transformation_transpose,
)
from tests.ut.test_miscellaneous import numpy_value, value_with_type

# -----------------------------------------------------------------------------
# transformation_astype
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_astype_basic():
    da_in = DataArray(np.arange(4, dtype=np.int32), dims=["x"], attrs={"a": 1})
    out = transformation_astype(da_in, "float32")
    assert out.dtype == np.float32
    assert out.attrs["a"] == 1
    assert out.attrs[DTYPE] == "float32"


@pytest.mark.unit
def test_transformation_astype_invalid_type():
    da_in = DataArray([1, 2])
    with pytest.raises(TypeError):
        transformation_astype(da_in, "does_not_exist")


@pytest.mark.unit
def test_transformation_astype_datetime64():
    da_in = DataArray(
        np.array(["2001-01-01", "2001-01-02"], dtype="datetime64[us]"), dims=["time"],
    )

    out = transformation_astype(da_in, "datetime64[ns]")

    # Missing CF-style units means datetime conversion is skipped.
    assert out is da_in
    assert out.dtype == np.dtype("datetime64[us]")


@pytest.mark.unit
def test_transformation_astype_datetime64_converts_offsets_from_units():
    da_in = DataArray(
        np.array([0, 1, 2], dtype=np.int64),
        dims=["time"],
        attrs={"units": "seconds since 2024-01-01T00:00:00Z", "keep": "me"},
        name="time_var",
    )

    out = transformation_astype_datetime64(da_in, "datetime64[ns]")

    assert out.name == "time_var"
    assert out.dims == ("time",)
    assert out.attrs == {"keep": "me"}
    np.testing.assert_array_equal(
        out.values,
        np.array(
            [
                "2024-01-01T00:00:00.000000000",
                "2024-01-01T00:00:01.000000000",
                "2024-01-01T00:00:02.000000000",
            ],
            dtype="datetime64[ns]",
        ),
    )


@pytest.mark.unit
@pytest.mark.parametrize(
    "attrs",
    [
        {},
        {"units": "not a cf time unit"},
        {"units": "days since 2024-01-01T00:00:00"},
        {"units": "seconds since not-a-date"},
    ],
)
def test_transformation_astype_datetime64_returns_input_for_invalid_units(attrs):
    da_in = DataArray(np.array([0, 1], dtype=np.int64), dims=["time"], attrs=attrs)

    out = transformation_astype_datetime64(da_in, "datetime64[ns]")

    assert out is da_in


@pytest.mark.unit
def test_transformation_astype_datetime64_returns_non_dataarray_unchanged():
    dataset = DataArray([1]).to_dataset(name="value")

    out = transformation_astype_datetime64(dataset, "datetime64[ns]")

    assert out is dataset


# -----------------------------------------------------------------------------
# expand, squeeze, transpose
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_expand_dims():
    da_in = DataArray(np.arange(3), dims=["x"])
    out = transformation_expand_dims(da_in, {"axis": [0], "dimensions": ["z", "x"]})
    assert out.dims == ("z", "x")
    assert out.shape == (1, 3)


@pytest.mark.unit
def test_transformation_expand_dims_missing_params():
    da_in = DataArray([1])
    with pytest.raises(KeyError):
        transformation_expand_dims(da_in, {"axis": [0]})


@pytest.mark.unit
def test_transformation_squeeze():
    da_in = DataArray(np.zeros((1, 3)), dims=["z", "x"])
    out = transformation_squeeze(da_in, {"axis": [0], "dimensions": ["x"]})
    assert out.dims == ("x",)
    assert out.shape == (3,)


@pytest.mark.unit
def test_transformation_transpose():
    da_in = DataArray(np.zeros((2, 3)), dims=["a", "b"], name="v")
    out = transformation_transpose(da_in, [1, 0])

    # dims unchanged
    assert out.dims == ("a", "b")

    # but data WAS transposed
    assert out.data.shape == (3, 2)


# -----------------------------------------------------------------------------
# transformation_dopplerTime
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_dopplerTime():
    # 26-character timestamp as bytes
    chars = np.frombuffer(b"2001-01-01 00:00:00.000000", dtype="S1")

    # Build (1,1,26,26)
    arr = np.tile(chars, (1, 1, 26, 1))  # replicate rows
    arr = da.from_array(arr)

    da_in = DataArray(arr, dims=("a", "b", "c", "d"))

    out = transformation_dopplerTime(da_in, [0, 1, 2])

    # dims are third dimension removed
    assert out.dims == ("a", "b", "c")

    # shape must be (1,1,26)
    assert out.shape == (1, 1, 26)


# -----------------------------------------------------------------------------
# transformation_dimensions
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_dimensions_reorder_and_rename():
    da_in = DataArray(np.zeros((2, 3)), dims=("x", "y"))
    out = transformation_dimensions(da_in, ["y", "z"])

    # new names applied
    assert out.dims == ("y", "z")

    # shape does NOT change
    assert out.shape == (2, 3)


@pytest.mark.unit
def test_transformation_dimensions_wrong_length():
    da_in = DataArray(np.zeros((2, 3)), dims=("x", "y"))
    with pytest.raises(ValueError):
        transformation_dimensions(da_in, ["a"])


# -----------------------------------------------------------------------------
# transformation_attributes
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_attributes_basic():
    da_in = DataArray([1], attrs={"a": 1})
    out = transformation_attributes(da_in, {"b": 2})
    assert out.attrs["a"] == 1
    assert out.attrs["b"] == 2


@pytest.mark.unit
def test_transformation_attributes_includes_dtype_cast():
    da_in = DataArray([1], attrs={})
    out = transformation_attributes(da_in, {DTYPE: "float32"})
    assert out.dtype == np.float32
    assert out.attrs[DTYPE] == "float32"


# -----------------------------------------------------------------------------
# transformation_sub_array
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_sub_array_basic():
    da_in = DataArray(np.arange(5), dims=["x"])
    out = transformation_sub_array(da_in, {"indexers": {"x": slice(1, 3)}})
    assert np.array_equal(out.values, [1, 2])


# -----------------------------------------------------------------------------
# bit packing
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_pack_bits_axis_name():
    da_in = DataArray(np.array([[0], [1], [1], [0]], dtype=np.uint8), dims=["bit", "x"])

    # axis="bit" → remove that dimension
    out = transformation_pack_bits(da_in, "bit")

    assert out.dims == ("x",)
    assert out.shape == (1,)


@pytest.mark.unit
def test_transformation_pack_bits_axis_index():
    da_in = DataArray(np.array([[0], [1], [1], [0]], dtype=np.uint8), dims=["bit", "x"])

    out = transformation_pack_bits(da_in, 0)

    assert out.dims == ("x",)
    assert out.shape == (1,)


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis",
    [
        (
                DataArray(name="test", data=da.from_array(np.zeros((5, 5), dtype=bool))),
                "dim_1",
        ),
    ],
)
def test_transformation_pack_bits(var, axis):
    print(var.dims)
    transformed = transformation_pack_bits(var, axis)
    assert len(transformed.data.shape) == len(var.data.shape) - 1


# -----------------------------------------------------------------------------
# rechunk
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_rechunk():
    da_in = DataArray(da.arange(10), dims=["x"])
    out = transformation_rechunk(da_in, {"x": 5})
    assert out.chunks[0] == (5, 5)


# -----------------------------------------------------------------------------
# mask & scale
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_mask_and_scale_updates_attrs():
    da_in = DataArray([1.0])
    params = {
        VALID_MIN: 0,
        VALID_MAX: 10,
        FILL_VALUE: -1,
        SCALE_FACTOR: 2.0,
        ADD_OFFSET: 5.0,
        TARGET_DTYPE: "int16",
    }
    out = transformation_mask_and_scale_attributes(da_in, params)

    assert out.attrs[VALID_MIN] == 0
    assert out.attrs[VALID_MAX] == 10
    assert out.attrs[XARRAY_FILL_VALUE] == -1
    assert out.attrs[SCALE_FACTOR] == 2.0
    assert out.attrs[ADD_OFFSET] == 5.0
    assert out.attrs[TARGET_DTYPE] == "int16"


# -----------------------------------------------------------------------------
# transformation_apply_spacing
# -----------------------------------------------------------------------------


@pytest.mark.unit
def test_transformation_apply_spacing(tmp_path):
    xml = """
    <root>
        <spacing>2.0</spacing>
        <nlines>5</nlines>
    </root>
    """

    xml_file = tmp_path / "test.xml"
    xml_file.write_text(xml)

    da_in = DataArray(np.array([10.0]))

    params = {
        "basepath": tmp_path,
        "relpath": "test.xml",
        "spacing": "spacing",
        "n_lines": "nlines",
    }

    out = transformation_apply_spacing(da_in, params)

    # coeff = 2.0 * (5 - 1) = 8.0 → output = 10 * 8 = 80
    print(out)
    assert float(out.squeeze().item()) == 80.0


@pytest.mark.unit
def test_transformation_apply_spacing_missing_params():
    da_in = DataArray([1.0])
    with pytest.raises(KeyError):
        transformation_apply_spacing(da_in, {"basepath": ".", "relpath": "x"})


@pytest.mark.unit
def test_transformation_apply_spacing_wrong_type():
    with pytest.raises(TypeError):
        transformation_apply_spacing("not_dataarray", {})


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
            st.lists(
                elements=st.floats(allow_infinity=False, allow_nan=False),
                unique=True,
                min_size=10,
            ),
            float,
            list,
        ),
        value_with_type(
            st.lists(elements=st.integers(), unique=True, min_size=10), int, list,
        ),
        value_with_type(
            st.lists(elements=st.booleans(), unique=True, min_size=2), int, list,
        ),
        value_with_type(
            st.sets(
                elements=st.floats(allow_infinity=False, allow_nan=False), min_size=10,
            ),
            float,
            set,
        ),
        value_with_type(st.sets(elements=st.integers(), min_size=10), int, set),
        value_with_type(st.sets(elements=st.booleans(), min_size=2), int, set),
        value_with_type(
            st.dictionaries(st.text(), st.integers(), min_size=10), int, dict,
        ),
        value_with_type(
            st.dictionaries(st.text(), st.booleans(), min_size=10), int, dict,
        ),
        value_with_type(
            st.dictionaries(
                st.text(), st.floats(allow_infinity=False, allow_nan=False), min_size=10,
            ),
            float,
            dict,
        ),
        value_with_type(
            xps.arrays(xps.floating_dtypes(), 10, unique=True), float, list,
        ),
        value_with_type(xps.arrays(xps.integer_dtypes(), 10, unique=True), int, list),
        value_with_type(xps.arrays(xps.boolean_dtypes(), 10, unique=True), int, list),
    ),
)
def test_conv_sequences_bis(value_and_types: tuple[Any, type, type]):
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
        assert converted_value == conv_value or (
                converted_value != converted_value and conv_value != conv_value
        )


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
            elements=numpy_value(
                xps.floating_dtypes(), allow_infinity=False, allow_nan=False,
            ),
            expected_type=float,
        ),
        value_with_type(
            elements=numpy_value(
                xps.integer_dtypes(), allow_infinity=False, allow_nan=False,
            ),
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
            st.integers(
                min_value=np.iinfo("int64").min, max_value=np.iinfo("int64").max,
            ),
            int,
            xps.integer_dtypes(endianness="=", sizes=(64,)),
        ),
        value_with_type(
            st.integers(
                min_value=np.iinfo("int32").min, max_value=np.iinfo("int32").max,
            ),
            int,
            xps.integer_dtypes(endianness="=", sizes=(32,)),
        ),
        value_with_type(
            st.integers(
                min_value=np.iinfo("int16").min, max_value=np.iinfo("int16").max,
            ),
            int,
            xps.integer_dtypes(endianness="=", sizes=(16,)),
        ),
        value_with_type(
            st.integers(min_value=np.iinfo("int8").min, max_value=np.iinfo("int8").max),
            int,
            xps.integer_dtypes(endianness="=", sizes=(8,)),
        ),
        value_with_type(
            st.floats(width=16), float, xps.floating_dtypes(endianness="=", sizes=(16,)),
        ),
        value_with_type(
            st.floats(width=32), float, xps.floating_dtypes(endianness="=", sizes=(32,)),
        ),
        value_with_type(
            st.floats(width=64), float, xps.floating_dtypes(endianness="=", sizes=(64,)),
        ),
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
        (np.uint16, 0, 0),
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
    [
        (
                np.array([[5, 6, 7, 8], [6, 7, 8, 9], [7, 8, 9, 10]]),
                np.array([[9, 9, 8, 8], [7, 7, 6, 6], [5, 5, 4, 4]]),
        ),
    ],
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
        (
                DataArray(name="test", data=da.from_array(np.zeros((5, 5)))),
                [0],
                ("x", "y", "z"),
        ),
    ],
)
def test_transformation_expand_dims_bis(var, axis, dimensions):
    transformed = transformation_expand_dims(
        var, {"axis": axis, "dimensions": dimensions},
    )
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
                DataArray(
                    name="test", data=da.from_array(np.zeros((50, 20)), chunks=(5, 5)),
                ),
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
def test_transformation_rechunk_bis(var, outchunk, expected):
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
def test_transformation_squeeze_bis(var, axis, dimensions):
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
def test_transformation_transpose_bis(var, axis, new_shape):
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
        (
                DataArray(name="test", data=da.from_array(np.zeros((5, 5)))),
                {"units": "meters"},
        ),
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
        (
                DataArray(name="test", data=da.from_array(np.zeros((5, 5)))),
                {"dim_0": 0},
                ("dim_1",),
        ),
    ],
)
def test_transformation_sub_array(var, selector, result):
    transformed = transformation_sub_array(var, selector)
    assert transformed.dims == result


@pytest.mark.unit
@pytest.mark.parametrize(
    "var, axis",
    [
        (
                DataArray(name="test", data=da.from_array(np.zeros((5, 5), dtype=bool))),
                "dim_1",
        ),
    ],
)
def test_transformation_pack_bits_bis(var, axis):
    print(var.dims)
    transformed = transformation_pack_bits(var, axis)
    assert len(transformed.data.shape) == len(var.data.shape) - 1
