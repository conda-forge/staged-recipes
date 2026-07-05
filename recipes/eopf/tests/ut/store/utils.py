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

from eopf.store.reader_registry import EOReaderRegistry
from eopf.store.writer_registry import EOWriterRegistry


@pytest.fixture
def isolated_reader_registry():
    previous = EOReaderRegistry.available()
    EOReaderRegistry.clear()
    try:
        yield
    finally:
        EOReaderRegistry.clear()
        for name, reader_cls in previous.items():
            EOReaderRegistry.register(name)(reader_cls)


@pytest.fixture
def isolated_writer_registry():
    previous = EOWriterRegistry.available()
    previous_discoverability = {
        name: EOWriterRegistry.is_discoverable_by_target(name)
        for name in previous
    }
    EOWriterRegistry.clear()
    try:
        yield
    finally:
        EOWriterRegistry.clear()
        for name, writer_cls in previous.items():
            EOWriterRegistry.register(
                name,
                discoverable_by_target=previous_discoverability[name],
            )(writer_cls)
