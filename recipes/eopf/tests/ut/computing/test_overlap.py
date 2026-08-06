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
import doctest

import numpy as np
import pytest
import xarray as xr
from xarray import DataArray, Dataset

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")

from eopf.computing import overlap  # noqa: E402
from eopf.computing.overlap import map_overlap  # noqa: E402

from . import raise_if_dask_computes  # noqa: E402


@pytest.mark.unit
def test_overlap_doctests() -> None:
    doctest.testmod(overlap, verbose=True, raise_on_error=True)


@pytest.mark.parametrize(
    "obj",
    [
        DataArray([1] * 9),
        Dataset({"foo": ("dim_0", [1] * 9)}),
    ],
)
def test_map_overlap_is_lazy(obj: DataArray | Dataset) -> None:
    with raise_if_dask_computes():
        result = map_overlap(
            lambda obj: obj**2,
            obj.chunk(2),
            depth=1,
            boundary=0,
        )
    assert result.chunksizes == {"dim_0": (2, 2, 2, 2, 1)}


@pytest.mark.unit
def test_map_overlap_dataarray(dask_context) -> None:
    da = DataArray(
        [1, 1, 2, 3, 3, 3, 2, 1, 1],
        name="foo",
        dims="dim_0",
        coords={"dim_0": list("abcdefghi")},
        attrs={"foo": "bar"},
    ).chunk(2)
    expected = da.copy(data=[1, 0, 1, 1, 0, 0, -1, -1, 0])
    actual = map_overlap(
        lambda obj: obj - obj.roll(dim_0=1),
        da,
        depth=1,
        boundary=0,
        template=da,
    )
    xr.testing.assert_identical(expected, actual)
    assert actual.chunksizes == {"dim_0": (2, 2, 2, 2, 1)}


@pytest.mark.unit
def test_map_overlap_dataset(dask_context) -> None:
    ds = Dataset(
        {
            "foo": DataArray(np.arange(8).reshape(2, 4)),
            "bar": DataArray(np.arange(4), dims="dim_1"),
        },
        coords={"dim_0": list("ab"), "dim_1": range(4)},
    ).chunk(dim_0=1, dim_1=2)
    expected = ds.copy(
        data={
            "foo": [
                [0, 2, 4, 6],
                [4, 6, 8, 10],
            ],
            "bar": [0, 2, 4, 6],
        },
    )
    actual = map_overlap(
        lambda ds: ds + ds["bar"],
        ds,
        depth=1,
        boundary="reflect",
    )
    xr.testing.assert_identical(expected, actual)
    assert actual.chunksizes == {"dim_0": (1, 1), "dim_1": (2, 2)}


@pytest.mark.unit
def test_map_overlap_args(dask_context) -> None:
    foo = DataArray(np.arange(8).reshape(2, 4), name="foo").chunk(dim_0=1, dim_1=2)
    bar = DataArray(np.arange(4), dims="dim_1", name="bar").chunk(dim_1=2)
    expected = foo.copy(
        data=[
            [0, 2, 4, 6],
            [4, 6, 8, 10],
        ],
    )
    actual = map_overlap(
        lambda foo, bar: (foo + bar).rename("foo"),
        foo,
        depth=1,
        boundary="reflect",
        args=(bar,),
    )
    xr.testing.assert_identical(expected, actual)
    assert actual.chunksizes == {"dim_0": (1, 1), "dim_1": (2, 2)}


@pytest.mark.unit
@pytest.mark.parametrize(
    "boundary,data",
    [
        (
            "reflect",
            [
                [16, 17, 18, 19],
                [20, 21, 22, 23],
                [24, 25, 26, 27],
                [28, 29, 30, 31],
            ],
        ),
        (
            {"dim_0": "reflect", "dim_1": "none"},
            [
                [12, 13, 14, 15],
                [16, 17, 18, 19],
                [20, 21, 22, 23],
                [24, 25, 26, 27],
            ],
        ),
    ],
)
def test_map_overlap_boundaries(dask_context, boundary: str | dict[str, str], data: list[list[int]]) -> None:
    obj = DataArray(
        np.arange(16).reshape((4, 4)),
        name="foo",
    ).chunk(2)
    expected = obj.copy(data=data)

    actual = map_overlap(
        lambda obj: obj + obj.size,
        obj,
        depth=1,
        boundary=boundary,
    )
    xr.testing.assert_identical(expected, actual)
    assert actual.chunksizes == {"dim_0": (2, 2), "dim_1": (2, 2)}


@pytest.mark.unit
def test_map_overlap_uneven_chunks(dask_context) -> None:
    ds = Dataset(
        {
            "foo": DataArray(range(8)).chunk(4),
            "bar": DataArray(range(8)).chunk(2),
        },
    )
    with pytest.raises(ValueError, match=r"unify_chunks()"):
        map_overlap(
            lambda obj: obj,
            ds,
            depth=1,
            boundary="reflect",
        )


@pytest.mark.unit
def test_map_overlap_no_chunks(dask_context) -> None:
    da = DataArray(range(8))
    with pytest.raises(ValueError, match=r"Object is not chunked."):
        map_overlap(
            lambda obj: obj,
            da,
            depth=1,
            boundary="reflect",
        )


@pytest.mark.unit
def test_map_overlap_unknown_dims(dask_context) -> None:
    da = DataArray(range(8)).chunk()
    with pytest.raises(
        ValueError,
        match=r"Unknown 'depth' or 'boundary' dimensions: {'dim_0'}.",
    ):
        map_overlap(
            lambda obj: obj,
            da,
            depth={"dim_1": 0},
            boundary="reflect",
        )


@pytest.mark.unit
def test_map_overlap_asymmetric(dask_context) -> None:
    da = DataArray(np.arange(64).reshape((8, 8)), name="foo").chunk(4)
    expected = DataArray(
        [
            [0, 1, 2, 3, 3, 4, 5, 6, 7],
            [8, 9, 10, 11, 11, 12, 13, 14, 15],
            [16, 17, 18, 19, 19, 20, 21, 22, 23],
            [24, 25, 26, 27, 27, 28, 29, 30, 31],
            [16, 17, 18, 19, 19, 20, 21, 22, 23],
            [24, 25, 26, 27, 27, 28, 29, 30, 31],
            [32, 33, 34, 35, 35, 36, 37, 38, 39],
            [40, 41, 42, 43, 43, 44, 45, 46, 47],
            [48, 49, 50, 51, 51, 52, 53, 54, 55],
            [56, 57, 58, 59, 59, 60, 61, 62, 63],
        ],
        name="foo",
    )
    actual = map_overlap(
        lambda da: da,
        da,
        depth={"dim_0": (2, 0), "dim_1": (1, 0)},
        boundary="none",
        trim=False,
    )
    xr.testing.assert_identical(expected, actual)
    assert actual.chunksizes == {"dim_0": (4, 6), "dim_1": (4, 5)}


@pytest.mark.unit
@pytest.mark.parametrize(
    "obj",
    [
        DataArray([1, 2, 3, 4], name="foo"),
        Dataset({"foo": ("dim_0", [1, 2, 3, 4])}),
    ],
)
def test_map_overlap_vs_map_blocks(dask_context, obj: DataArray | Dataset) -> None:
    obj = obj.chunk(2)
    expected = xr.map_blocks(lambda obj: obj**2, obj)
    actual = map_overlap(lambda obj: obj**2, obj)
    xr.testing.assert_identical(expected, actual)
