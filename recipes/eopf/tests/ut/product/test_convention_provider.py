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
import pytest

from eopf.product.product_convention_provider import configure_product_convention, get_product_convention
from eopf.product.product_stac_convention import StacProductConvention


class DummyProductConvention:
    @staticmethod
    def product_type(_dtree):  # pragma: no cover - test helper
        return "dummy"

    @staticmethod
    def set_product_type(_dtree, _value):  # pragma: no cover - test helper
        return None

    @staticmethod
    def product_id(_dtree, mission_specific=None):  # pragma: no cover - test helper
        return "dummy"

    @staticmethod
    def product_kind(_dtree):  # pragma: no cover - test helper
        return "eoproduct"

    @staticmethod
    def set_product_kind(_dtree, _value):  # pragma: no cover - test helper
        return None

    @staticmethod
    def processing_version(_dtree):  # pragma: no cover - test helper
        return None

    @staticmethod
    def set_processing_version(_dtree, _value):  # pragma: no cover - test helper
        return None

    @staticmethod
    def processing_software(_dtree):  # pragma: no cover - test helper
        return None

    @staticmethod
    def add_processing_software_entry(  # pragma: no cover - test helper
        _dtree,
        _software_name,
        _software_version,
    ):
        return None

    @staticmethod
    def remove_processing_software_entry(_dtree, _software_name):  # pragma: no cover - test helper
        return None

    @staticmethod
    def clear_processing_software(_dtree):  # pragma: no cover - test helper
        return None

    @staticmethod
    def assets(_dtree):  # pragma: no cover - test helper
        return {}

    @staticmethod
    def get_asset(_dtree, _key):  # pragma: no cover - test helper
        return None

    @staticmethod
    def set_asset(_dtree, _key, _asset):  # pragma: no cover - test helper
        return None

    @staticmethod
    def remove_asset(_dtree, _key, *, missing_ok=True):  # pragma: no cover - test helper
        return None

    @staticmethod
    def clear_assets(_dtree):  # pragma: no cover - test helper
        return None

    @staticmethod
    def populate_assets_with_shortnames(_dtree, _short_names):  # pragma: no cover - test helper
        return None


@pytest.fixture(autouse=True)
def reset_convention_provider(monkeypatch):
    monkeypatch.setattr(
        "eopf.product.product_convention_provider._product_convention",
        StacProductConvention,
    )
    monkeypatch.setattr(
        "eopf.product.product_convention_provider._product_convention_locked",
        False,
    )


@pytest.mark.unit
def test_get_product_convention_returns_default():
    assert get_product_convention() is StacProductConvention


@pytest.mark.unit
def test_configure_product_convention_only_allows_one_configuration():
    configure_product_convention(DummyProductConvention)

    assert get_product_convention() is DummyProductConvention

    with pytest.raises(RuntimeError, match="Product convention has already been requested, can't be changed !!!"):
        configure_product_convention(StacProductConvention)
