# Test for recursive_update
import pytest
from xarray import DataTree

from eopf.common.constants import EOCONTAINER_CATEGORY, EOPRODUCT_CATEGORY
from eopf.common.file_utils import AnyPath
from eopf.store.mapping_manager import EOPFMappingManager
from eopf.store.product_specific.L0 import (
    L0GenericSafeFinalize,
    propagate_attrs_to_descendants,
    recursive_copy_attrs_to_products,
)


@pytest.mark.unit
def test_recursive_update():
    d1 = {
        "other_metadata": {"a1": 1},
        "properties": {"b": 2},
        "normal_key": "old_value",
    }
    d2 = {
        "other_metadata": {"a1": 2, "a2": 3},
        "properties": {"b": 3},
        "normal_key": "new_value",
        "new_key": "new_value",
    }
    new_attrs = propagate_attrs_to_descendants(d1, d2)
    assert new_attrs["other_metadata"]["a1"] == 1  # keep existing
    assert new_attrs["other_metadata"]["a2"] == 3  # add new value
    assert new_attrs["properties"]["b"] == 2  # keep existing
    assert new_attrs["normal_key"] == "old_value"
    assert new_attrs["new_key"] == "new_value"


# Test for recursive_copy_attrs_to_products
@pytest.mark.unit
def test_recursive_copy_attrs_to_products():
    reference_dict = {"key1": "value1", "key2": {"subkey": "subvalue"}}
    product = DataTree(name="p")
    product.attrs = {"key1": "old_value"}
    product.cpm.product_kind = EOPRODUCT_CATEGORY
    container = DataTree(name="c")
    container["child"] = product
    container.attrs = reference_dict
    container.cpm.product_kind = EOCONTAINER_CATEGORY
    recursive_copy_attrs_to_products(container, container.attrs)
    assert container["child"].attrs["key1"] == "old_value"
    assert container["child"].attrs["key2"]["subkey"] == "subvalue"


# Test for adding new keys
@pytest.mark.unit
def test_recursive_update_new_keys():
    d1 = {"existing_key": "existing_value"}
    d2 = {"new_key": "new_value"}
    new_attrs = propagate_attrs_to_descendants(d1, d2)
    assert new_attrs["existing_key"] == "existing_value"
    assert new_attrs["new_key"] == "new_value"


# Test for nested dictionaries
@pytest.mark.unit
def test_recursive_update_nested_dicts():
    d1 = {"nested": {"key": "old_value"}}
    d2 = {"nested": {"key": "new_value", "new_key": "new_value"}}
    new_attrs = propagate_attrs_to_descendants(d1, d2)
    assert new_attrs["nested"]["key"] == "old_value"
    assert "new_key" not in new_attrs["nested"]  # not added because nested is not replaced

    d1 = {"stac_discovery": {"properties": {"key": "old_value"}}}
    d2 = {"stac_discovery": {"properties": {"key": "new_value", "new_key": "new_value"}}}
    new_attrs = propagate_attrs_to_descendants(d1, d2)
    assert new_attrs["stac_discovery"]["properties"]["key"] == "old_value"
    assert (
            new_attrs["stac_discovery"]["properties"]["new_key"] == "new_value"
    )  # added because correspond to path to update


# Test for EOContainer with multiple EOProducts
@pytest.mark.unit
def test_recursive_copy_attrs_to_products_multiple():
    reference_dict = {"key1": "value1"}
    product1 = DataTree(name="p1")
    product1.attrs = {"key1": "old_value1"}
    product1.cpm.product_kind = EOPRODUCT_CATEGORY
    product2 = DataTree(name="p2")
    product2.attrs = {"key2": "old_value2"}
    product2.cpm.product_kind = EOPRODUCT_CATEGORY
    container = DataTree(name="c")
    container.cpm.product_kind = EOCONTAINER_CATEGORY
    container["p1"] = product1
    container["p2"] = product2
    recursive_copy_attrs_to_products(container, reference_dict)
    assert container["p1"].attrs == {
        "key1": "old_value1",
        "other_metadata": {"eopf_category": "eoproduct"},
    }
    assert container["p2"].attrs == {
        "key1": "value1",
        "key2": "old_value2",
        "other_metadata": {"eopf_category": "eoproduct"},
    }


@pytest.mark.unit
def test_finalize_class_l0_generic_safe_finalize():
    product11 = DataTree(name="p11")
    product11.attrs = {"other_metadata": {"a11": "v11"}}
    product11.cpm.product_kind = EOPRODUCT_CATEGORY
    product12 = DataTree(name="p12")
    product12.attrs = {"other_metadata": {"a12": "v12"}}
    product12.cpm.product_kind = EOPRODUCT_CATEGORY
    product21 = DataTree(name="p21")
    product21.attrs = {"other_metadata": {"a21": "v21"}}
    product21.cpm.product_kind = EOPRODUCT_CATEGORY
    product22 = DataTree(name="p22")
    product22.attrs = {"other_metadata": {"a22": "v22"}}
    product22.cpm.product_kind = EOPRODUCT_CATEGORY
    container = DataTree(name="c")
    container.attrs = {"other_metadata": {"common": True}, "stac_discovery": {"properties": {"stac1": 1}}}
    container.cpm.product_kind = EOCONTAINER_CATEGORY
    container["c1"] = DataTree(name="c1")
    container["c1"].cpm.product_kind = EOCONTAINER_CATEGORY
    container["c2"] = DataTree(name="c2")
    container["c2"].cpm.product_kind = EOCONTAINER_CATEGORY
    container["c1"]["p11"] = product11
    container["c1"]["p12"] = product12
    container["c2"]["p21"] = product21
    container["c2"]["p22"] = product22
    container.cpm.product_kind = EOCONTAINER_CATEGORY

    url = AnyPath("some/fake/path")
    mapping = {"key": "value"}
    mapping_manager = EOPFMappingManager()

    product_finalizer = L0GenericSafeFinalize()
    container = product_finalizer.finalize(container, url, mapping, mapping_manager)

    assert container["c1"].attrs["other_metadata"] == {"common": True, "eopf_category": "eocontainer"}
    assert container["c2"].attrs["other_metadata"] == {"common": True, "eopf_category": "eocontainer"}
    assert container["c1"].attrs["stac_discovery"]["properties"] == {"stac1": 1}
    assert container["c2"].attrs["stac_discovery"]["properties"] == {"stac1": 1}

    assert container["c1"]["p11"].attrs == {
        "other_metadata": {"common": True, "a11": "v11", "eopf_category": "eoproduct"},
        "stac_discovery": {"properties": {"stac1": 1}},
    }
    assert container["c1"]["p12"].attrs == {
        "other_metadata": {"common": True, "a12": "v12", "eopf_category": "eoproduct"},
        "stac_discovery": {"properties": {"stac1": 1}},
    }
    assert container["c2"]["p21"].attrs == {
        "other_metadata": {"common": True, "a21": "v21", "eopf_category": "eoproduct"},
        "stac_discovery": {"properties": {"stac1": 1}},
    }
    assert container["c2"]["p22"].attrs == {
        "other_metadata": {"common": True, "a22": "v22", "eopf_category": "eoproduct"},
        "stac_discovery": {"properties": {"stac1": 1}},
    }
