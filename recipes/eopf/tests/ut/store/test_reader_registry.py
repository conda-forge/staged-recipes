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
""" """

import pytest

from eopf.exceptions.errors import EONoRegisteredReaderError, EONoRegisteredWriterError
from eopf.store.reader_registry import EOReaderRegistry

from .utils import isolated_reader_registry


class _FakeReaderA:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".a")


class _FakeReaderB:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        value = str(filename_or_obj)
        return value.endswith(".b") or value.endswith(".common")


class _FakeReaderC:
    @classmethod
    def guess_can_open(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".common")


@pytest.mark.unit
def test_register_adds_reader(isolated_reader_registry):
    decorated = EOReaderRegistry.register("reader_a")(_FakeReaderA)

    assert decorated is _FakeReaderA
    assert EOReaderRegistry.contains("reader_a") is True
    assert EOReaderRegistry.get_by_name("reader_a") is _FakeReaderA


@pytest.mark.unit
def test_register_raises_when_name_already_exists(isolated_reader_registry):
    EOReaderRegistry.register("reader_a")(_FakeReaderA)

    with pytest.raises(ValueError, match=r"Reader 'reader_a' already registered"):
        EOReaderRegistry.register("reader_a")(_FakeReaderB)


@pytest.mark.unit
def test_get_candidates_by_target_returns_single_match(isolated_reader_registry):
    EOReaderRegistry.register("reader_a")(_FakeReaderA)
    EOReaderRegistry.register("reader_b")(_FakeReaderB)

    candidates = EOReaderRegistry.get_candidates_by_target("product.a")

    assert candidates == [_FakeReaderA]


@pytest.mark.unit
def test_get_candidates_by_target_returns_multiple_matches(isolated_reader_registry):
    EOReaderRegistry.register("reader_b")(_FakeReaderB)
    EOReaderRegistry.register("reader_c")(_FakeReaderC)

    candidates = EOReaderRegistry.get_candidates_by_target("product.common")

    assert candidates == [_FakeReaderB, _FakeReaderC]


@pytest.mark.unit
def test_get_candidates_by_target_raises_when_no_match(isolated_reader_registry):
    EOReaderRegistry.register("reader_a")(_FakeReaderA)

    with pytest.raises(
        EONoRegisteredReaderError,
        match=r"No registered reader compatible with filename : product.unknown",
    ):
        EOReaderRegistry.get_candidates_by_target("product.unknown")


@pytest.mark.unit
def test_get_by_name_returns_registered_reader(isolated_reader_registry):
    EOReaderRegistry.register("reader_b")(_FakeReaderB)

    reader_cls = EOReaderRegistry.get_by_name("reader_b")

    assert reader_cls is _FakeReaderB


@pytest.mark.unit
def test_get_by_name_raises_when_missing(isolated_reader_registry):
    with pytest.raises(
        EONoRegisteredWriterError,
        match=r"No registered reader with format : missing_reader",
    ):
        EOReaderRegistry.get_by_name("missing_reader")


@pytest.mark.unit
def test_available_returns_copy_of_registry(isolated_reader_registry):
    EOReaderRegistry.register("reader_a")(_FakeReaderA)

    available = EOReaderRegistry.available()
    available["reader_b"] = _FakeReaderB

    assert EOReaderRegistry.available() == {"reader_a": _FakeReaderA}


@pytest.mark.unit
def test_contains_returns_true_when_registered_and_false_otherwise(isolated_reader_registry):
    EOReaderRegistry.register("reader_a")(_FakeReaderA)

    assert EOReaderRegistry.contains("reader_a") is True
    assert EOReaderRegistry.contains("reader_b") is False
