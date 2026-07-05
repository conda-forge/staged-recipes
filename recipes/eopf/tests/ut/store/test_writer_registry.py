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

from eopf.exceptions.errors import (
    EOAmbiguousWriterError,
    EONoRegisteredWriterError,
)
from eopf.store.writer_registry import EOWriterRegistry

pytest_plugins = ("tests.ut.store.utils",)


class _FakeWriterA:
    @classmethod
    def guess_can_write(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".a")


class _FakeWriterB:
    @classmethod
    def guess_can_write(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".b")


class _FakeWriterCommon1:
    @classmethod
    def guess_can_write(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".common")


class _FakeWriterCommon2:
    @classmethod
    def guess_can_write(cls, filename_or_obj):
        return str(filename_or_obj).endswith(".common")


@pytest.mark.unit
def test_register_adds_writer(isolated_writer_registry):
    decorated = EOWriterRegistry.register("writer_a")(_FakeWriterA)

    assert decorated is _FakeWriterA
    assert EOWriterRegistry.contains("writer_a")
    assert EOWriterRegistry.get_by_name("writer_a") is _FakeWriterA


@pytest.mark.unit
def test_register_raises_if_name_exists(isolated_writer_registry):
    EOWriterRegistry.register("writer_a")(_FakeWriterA)

    with pytest.raises(ValueError, match=r"Writer 'writer_a' already registered"):
        EOWriterRegistry.register("writer_a")(_FakeWriterB)


@pytest.mark.unit
def test_get_by_target_returns_matching_writer(isolated_writer_registry):
    EOWriterRegistry.register("writer_a")(_FakeWriterA)
    EOWriterRegistry.register("writer_b")(_FakeWriterB)

    writer = EOWriterRegistry.get_by_target("output.a")

    assert writer is _FakeWriterA


@pytest.mark.unit
def test_get_by_target_raises_if_no_writer_found(isolated_writer_registry):
    EOWriterRegistry.register("writer_a")(_FakeWriterA)

    with pytest.raises(
        EONoRegisteredWriterError,
        match=r"No registered writer compatible with filename : output.unknown",
    ):
        EOWriterRegistry.get_by_target("output.unknown")


@pytest.mark.unit
def test_get_by_target_raises_if_multiple_writers_match(isolated_writer_registry):
    EOWriterRegistry.register("writer1")(_FakeWriterCommon1)
    EOWriterRegistry.register("writer2")(_FakeWriterCommon2)

    with pytest.raises(
        EOAmbiguousWriterError,
        match=r"Multiple writers are compatible with 'file.common'",
    ):
        EOWriterRegistry.get_by_target("file.common")


@pytest.mark.unit
def test_get_by_target_ignores_non_discoverable_writer(isolated_writer_registry):
    EOWriterRegistry.register("writer1")(_FakeWriterCommon1)
    EOWriterRegistry.register("writer2", discoverable_by_target=False)(_FakeWriterCommon2)

    writer = EOWriterRegistry.get_by_target("file.common")

    assert writer is _FakeWriterCommon1
    assert EOWriterRegistry.get_by_name("writer2") is _FakeWriterCommon2


@pytest.mark.unit
def test_get_by_name_returns_writer(isolated_writer_registry):
    EOWriterRegistry.register("writer_a")(_FakeWriterA)

    writer_cls = EOWriterRegistry.get_by_name("writer_a")

    assert writer_cls is _FakeWriterA


@pytest.mark.unit
def test_get_by_name_raises_when_missing():
    with pytest.raises(
        EONoRegisteredWriterError,
        match=r"No registered writer with format : missing_writer, available : .*",
    ):
        EOWriterRegistry.get_by_name("missing_writer")


@pytest.mark.unit
def test_available_returns_copy(isolated_writer_registry):
    EOWriterRegistry.register("writer_a")(_FakeWriterA)

    available = EOWriterRegistry.available()
    available["writer_b"] = _FakeWriterB

    assert EOWriterRegistry.available() == {"writer_a": _FakeWriterA}


@pytest.mark.unit
def test_contains():
    EOWriterRegistry.register("writer_a")(_FakeWriterA)

    assert EOWriterRegistry.contains("writer_a") is True
    assert EOWriterRegistry.contains("writer_b") is False
