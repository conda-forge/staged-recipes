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
from xarray import DataTree

from eopf.common.constants import EOPRODUCT_CATEGORY
from eopf.product.conveniences import enforce_eoproduct_rules, init_datatree


@pytest.mark.unit
def test_init_datatree_creates_standard_eoproduct_structure():
    product = init_datatree("test")

    assert product.cpm.product_kind == EOPRODUCT_CATEGORY
    assert "measurements" in product.children
    assert "quality" not in product.children
    assert "conditions" not in product.children
    assert "stac_discovery" in product.attrs
    assert "properties" in product.attrs["stac_discovery"]


@pytest.mark.unit
def test_init_datatree_preserves_kwargs():
    product = init_datatree("test", attrs={"foo": "bar"})

    assert product.attrs["foo"] == "bar"


@pytest.mark.unit
def test_init_datatree_can_skip_standard_structure():
    product = init_datatree("test", enforce_eoproduct_rules=False)

    assert "measurements" not in product.children
    assert "quality" not in product.children
    assert "conditions" not in product.children


@pytest.mark.unit
def test_enforce_eoproduct_rules_adds_missing_standard_nodes():
    product = DataTree(name="test")

    result = enforce_eoproduct_rules(product)

    assert result is product
    assert "measurements" in product.children
    assert "quality" not in product.children
    assert "conditions" not in product.children
