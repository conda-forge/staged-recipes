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
from pathlib import Path
from typing import TYPE_CHECKING, Any
from unittest import mock

import pytest
from xarray import DataArray

from eopf.accessor import (
    FromAttributesToFlagValueAccessor,
    FromAttributesToVariableAccessor,
)
from eopf.exceptions.errors import AccessorNotOpenError
from eopf.store.abstract import EOReader

if TYPE_CHECKING:  # pragma: no cover
    from xarray import DataTree


class FakeReaderBis(EOReader):
    EXTENSIONS = ".fakebis"

    def open_datatree(
        self,
        filename_or_obj: str | Path | Any,
        *,
        chunks: Any = None,
        cache: bool | None = None,
        decode_cf: bool | None = None,
        mask_and_scale: bool | dict[str, bool] | None = None,
        decode_times: bool | Any | None = None,
        decode_timedelta: bool | Any | None = None,
        use_cftime: bool | None = None,
        concat_characters: bool | None = None,
        decode_coords: str | bool | None = None,
        drop_variables: str | list[str] | None = None,
        create_default_indexes: bool = True,
        inline_array: bool = False,
        chunked_array_type: str | None = None,
        from_array_kwargs: dict[str, Any] | None = None,
        backend_kwargs: dict[str, Any] | None = None,
        **kwargs: Any,
    ) -> "DataTree":
        pass

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


@pytest.mark.unit
@pytest.mark.parametrize(
    "store, kwargs",
    [
        (FromAttributesToVariableAccessor(""), {}),
        (FromAttributesToFlagValueAccessor(""), {"flag_values": [1, 2, 3], "flag_meanings": [23, 1, 5]}),
    ],
)
@pytest.mark.parametrize("attrs, attr_name, index", [({"a": [23]}, "a", 0), ({"a": [23], "B": [1, 5, 23]}, "B", 1)])
def test_fromattributestovar_accessor(
    attrs: dict,
    store: FromAttributesToVariableAccessor,
    attr_name: str,
    index: Any,
    kwargs: dict,
):
    with (
        mock.patch.object(FakeReaderBis, "open_datatree", return_value=DataArray(attrs=attrs)),
    ):
        store.open(
            reader_cls="tests.ut.accessor.test_attribute_to_flag_var.FakeReaderBis",
            attr_name=attr_name,
            index=index,
            **kwargs,
        )
        assert store.get_data("value"), [attrs[attr_name][index]]

    with pytest.raises(NotImplementedError):
        store.write_attrs("", {})

    store.close()


@pytest.mark.unit
def test_fromattributestovar_accessor_errors():
    store = FromAttributesToVariableAccessor("")
    with pytest.raises(AccessorNotOpenError):
        store.close()
    with pytest.raises(AccessorNotOpenError):
        _ = store.get_data("value")


@pytest.mark.unit
@pytest.mark.parametrize(
    "store, kwargs",
    [
        (FromAttributesToVariableAccessor(""), {}),
        (FromAttributesToFlagValueAccessor(""), {"flag_values": [1, 2, 3], "flag_meanings": [23, 1, 5]}),
    ],
)
@pytest.mark.parametrize("attrs, attr_name, index", [({"a": [23]}, "a", 0), ({"a": [23], "B": [1, 5, 23]}, "B", 1)])
def test_fromattributestovarstore(
    attrs: dict,
    store: FromAttributesToVariableAccessor,
    attr_name: str,
    index: Any,
    kwargs: dict,
):
    with (
        mock.patch.object(FakeReaderBis, "open_datatree", return_value=DataArray(attrs=attrs)),
    ):
        store.open(
            reader_cls="tests.ut.accessor.test_attribute_to_flag_var.FakeReaderBis",
            attr_name=attr_name,
            index=index,
            **kwargs,
        )
        assert store._extract_data("value") == [attrs[attr_name][index]]

    with pytest.raises(NotImplementedError):
        store.write_attrs("", {})
