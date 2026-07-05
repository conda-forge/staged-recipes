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
"""
rasterio.py

EOAccessor implementation for rasterio data access

"""

import pytest
import xarray as xr
from xarray import DataTree

from eopf.exceptions.errors import EONoRegisteredReaderError
from eopf.store import open_datatree
from eopf.store.reader_registry import EOReaderRegistry
from eopf.store.safe_reader import EODataTreeSafeReader
from eopf.store.zarr_reader import EODataTreeZarrReader

from .utils import isolated_reader_registry  # noqa


class _FakeReaderSuccess:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".safe")

    def open_datatree(self, filename_or_obj, **kwargs):
        return DataTree(name="success")


class _FakeReaderFailA:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".multi")

    def open_datatree(self, filename_or_obj, **kwargs):
        raise ValueError("reader A failed")


class _FakeReaderFailB:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".multi")

    def open_datatree(self, filename_or_obj, **kwargs):
        raise RuntimeError("reader B failed")


class _FakeReaderSecondSucceeds:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".mixed")

    def open_datatree(self, filename_or_obj, **kwargs):
        return DataTree(name="second-success")


class _FakeReaderFirstFails:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".mixed")

    def open_datatree(self, filename_or_obj, **kwargs):
        raise ValueError("first failed")


@pytest.mark.unit
def test_open_datatree_uses_registered_reader_when_engine_is_explicit(isolated_reader_registry):
    EOReaderRegistry.register("fake")(_FakeReaderSuccess)

    result = open_datatree("product.safe", engine="fake")

    assert isinstance(result, DataTree)
    assert result.name == "success"


@pytest.mark.unit
def test_open_datatree_passes_open_kwargs_to_registered_reader(isolated_reader_registry):
    received = {}

    class _Reader:
        @classmethod
        def guess_can_open(cls, filename_or_obj):
            return True

        def open_datatree(self, filename_or_obj, **kwargs):
            received["filename_or_obj"] = filename_or_obj
            received["kwargs"] = kwargs
            return DataTree(name="ok")

    EOReaderRegistry.register("fake")(_Reader)

    result = open_datatree(
        "product.safe",
        engine="fake",
        chunks={"x": 10},
        cache=True,
        decode_cf=False,
        mask_and_scale=True,
        backend_kwargs={"a": 1},
        custom_kw="value",
    )

    assert result.name == "ok"
    assert received["filename_or_obj"] == "product.safe"
    assert received["kwargs"]["chunks"] == {"x": 10}
    assert received["kwargs"]["cache"] is True
    assert received["kwargs"]["decode_cf"] is False
    assert received["kwargs"]["mask_and_scale"] is True
    assert received["kwargs"]["backend_kwargs"] == {"a": 1}
    assert received["kwargs"]["custom_kw"] == "value"


@pytest.mark.unit
def test_open_datatree_delegates_to_xarray_when_engine_is_not_registered(monkeypatch, isolated_reader_registry):
    captured = {}

    def fake_xr_open_datatree(filename_or_obj, **kwargs):
        captured["filename_or_obj"] = filename_or_obj
        captured["kwargs"] = kwargs
        return DataTree(name="xarray-result")

    monkeypatch.setattr(xr, "open_datatree", fake_xr_open_datatree)

    result = open_datatree(
        "product.nc",
        engine="netcdf4",
        decode_cf=True,
        cache=False,
        another_kw=123,
    )

    assert result.name == "xarray-result"
    assert captured["filename_or_obj"] == "product.nc"
    assert captured["kwargs"]["engine"] == "netcdf4"
    assert captured["kwargs"]["decode_cf"] is True
    assert captured["kwargs"]["cache"] is False
    assert captured["kwargs"]["another_kw"] == 123


@pytest.mark.unit
def test_open_datatree_auto_mode_returns_first_successful_reader(isolated_reader_registry):
    EOReaderRegistry.register("fake")(_FakeReaderSuccess)

    result = open_datatree("product.safe")

    assert result.name == "success"


@pytest.mark.unit
def test_open_datatree_auto_mode_tries_next_reader_after_failure(isolated_reader_registry):
    EOReaderRegistry.register("first")(_FakeReaderFirstFails)
    EOReaderRegistry.register("second")(_FakeReaderSecondSucceeds)

    result = open_datatree("product.mixed")

    assert result.name == "second-success"


@pytest.mark.unit
def test_open_datatree_auto_mode_raises_aggregated_error_when_all_candidates_fail(isolated_reader_registry):
    EOReaderRegistry.register("a")(_FakeReaderFailA)
    EOReaderRegistry.register("b")(_FakeReaderFailB)

    with pytest.raises(
        EONoRegisteredReaderError,
        match=r"No registered EOReader was able to open 'product.multi'",
    ) as exc_info:
        open_datatree("product.multi")

    message = str(exc_info.value)
    assert "Tried 2 candidate(s)" in message
    assert "_FakeReaderFailA: reader A failed" in message
    assert "_FakeReaderFailB: reader B failed" in message


@pytest.mark.unit
def test_open_datatree_auto_mode_propagates_no_registered_reader_error_when_no_candidate_found(
    isolated_reader_registry,
):
    with pytest.raises(FileNotFoundError):
        open_datatree("product.unknown")


@pytest.mark.unit
def test_open_datatree_auto_mode_passes_open_kwargs_to_candidate_reader(isolated_reader_registry):
    received = {}

    class _Reader:
        @classmethod
        def guess_can_open(cls, filename_or_obj):
            return str(filename_or_obj).endswith(".safe")

        def open_datatree(self, filename_or_obj, **kwargs):
            received["filename_or_obj"] = filename_or_obj
            received["kwargs"] = kwargs
            return DataTree(name="ok")

    EOReaderRegistry.register("fake")(_Reader)

    result = open_datatree(
        "product.safe",
        chunks="auto",
        cache=True,
        decode_cf=False,
        inline_array=True,
        from_array_kwargs={"meta": "x"},
        custom_kw="hello",
    )

    assert result.name == "ok"
    assert received["filename_or_obj"] == "product.safe"
    assert received["kwargs"]["chunks"] == "auto"
    assert received["kwargs"]["cache"] is True
    assert received["kwargs"]["decode_cf"] is False
    assert received["kwargs"]["inline_array"] is True
    assert received["kwargs"]["from_array_kwargs"] == {"meta": "x"}
    assert received["kwargs"]["custom_kw"] == "hello"


@pytest.mark.unit
@pytest.mark.parametrize(
    "store, ok_formats",
    [
        (EODataTreeZarrReader, (".zarr", ".zarr.zip")),
        (EODataTreeSafeReader, (".SAFE", ".SEN3", ".SAFE.zip", ".SEN3.zip")),
    ],
)
def test_accepted_filenames(store, ok_formats):
    for format in ok_formats:
        print(f"file{format}")
        assert store.guess_can_open(f"file{format}")
