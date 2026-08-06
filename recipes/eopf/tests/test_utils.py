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
import glob
import logging
import os
from importlib.util import find_spec
from typing import Any, Optional, Union

import numpy as np
import pytest
from hypothesis import strategies as st
from xarray import DataArray, DataTree


def assert_has_coords(obj: "DataTree", coords: list[Union[str, DataTree]]):
    """Assert that"""
    assert len(obj.coordinates_dict) == len(coords)
    for c in obj.coordinates_dict:
        assert c in coords


def group_details(section_detail: dict, section_structure: dict) -> None:
    subgroup_structure = {}
    item_structure = {}
    item_names = section_detail.xpath("label/text()")
    item_name = None
    if item_names:
        item_name = str(item_names[-1]).strip("', :").strip()
    subgroup_names = section_detail.xpath("div/label/text()")
    subgroup_name = None
    if subgroup_names:
        subgroup_name = str(subgroup_names[-1]).strip("', :").strip()
    if item_name == "Attributes":
        attributes = section_detail.xpath("div/dl")
        if attributes:
            attr_name = attributes[0].xpath("dt/span/text()")
            attr_value = attributes[0].xpath("dd/text()")
            if attr_name and attr_value:
                item_structure[attr_name[0]] = attr_value[0]
                section_structure[item_name] = item_structure
            else:
                section_structure[item_name] = {}
    elif item_name == "Dimensions" or item_name == "Coordinates":
        dimensions = section_detail.xpath("div/div/text()")
        if dimensions:
            dimension_value = dimensions[-1].strip("', :").strip()
            dimension_value = dimension_value.partition("->")[2]
            section_structure[item_name] = dimension_value

    subgroups = section_detail.xpath("div/div/ul/li")
    if subgroups:
        for var in subgroups:
            group_details(var, subgroup_structure)
            section_structure[subgroup_name] = subgroup_structure
    elif subgroup_name:
        section_structure[subgroup_name] = {}


def _compute_rec(node):
    try:
        name = str(node.xpath("label/text()")[-1]).strip("', :").strip()
    except Exception:
        return {}
    sections = node.xpath("div/ul/li/div")
    structure = {}
    for section in sections:
        structure |= _compute_rec(section)

    node_attrs = node.xpath('div/ul/li/div/dl[@class="eopf-attrs"][1]/dd')
    attrs = {}
    coords = []
    if node_attrs:
        attrs = eval(node_attrs[0].text)
        if len(node_attrs) > 2:
            coords = [i.text for i in node_attrs[2:]]

    node_dims = node.xpath('div/ul/li/div/div[@class="eopf-section-inline-details"]')
    dims = []
    if node_dims:
        for d in node_dims[0].text.strip()[1:-1].split(","):
            d = d.strip()[1:-1]
            if d:
                dims.append(d)
    structure["dims"] = tuple(dims)

    structure["attrs"] = attrs
    structure["coords"] = coords
    return {name: structure}


def compute_tree_structure(tree) -> dict:
    root = tree.xpath("/html/body/div")[0]
    return _compute_rec(root)


def assert_contain(container: DataTree, path: str, expect_type, path_offset="/") -> None:
    obj = container[path]
    if expect_type == DataTree:
        assert obj.path == path_offset + path
    assert obj.name == path.rpartition("/")[2]
    assert isinstance(obj, expect_type)


def assert_issubdict(set_dict: dict, subset_dict: dict) -> bool:
    assert (set_dict | subset_dict) == set_dict


def compare_attrs(attrs1: dict, attrs2: dict):
    """
    Compare two attributes and return True if they are equal (excluding keys starting with '_'), False otherwise.

    Parameters
    ----------
    attrs1 : dict
        The first dictionary to compare.
    attrs2 : dict
        The second dictionary to compare.

    Returns
    -------
    bool
        True if the dictionaries are equal (excluding keys starting with '_'), False otherwise.
    """
    keys1 = [key for key in attrs1 if not key.startswith("_")]
    keys2 = [key for key in attrs2 if not key.startswith("_")]

    if set(keys1) != set(keys2):
        return False

    for key in keys1:
        if attrs1[key] != attrs2[key]:
            return False
    return True


def assert_datatree_distinct_equal(group1: "DataTree", group2: "DataTree"):
    """
    Compare two `EOGroup` objects for equality, without checking names.

    Parameters
    ----------
    group1 : DataTree
        The first DataTree object to compare.
    group2 : DataTree
        The second DataTree object to compare.

    Raises
    ------
    AssertionError
        If the groups have the same id or if their sizes mismatch.
        If their variables are differents

    Examples
    --------
    >>> group1 = DataTree(...)
    >>> group2 = DataTree(...)
    >>> assert_datatree_distinct_equal(group1, group2)

    """
    assert group1 is not group2, "groups id are the same"
    assert len(group1) == len(group2), "group's size mismatch"
    assert group1.attrs is not group2.attrs, "attributes id are the same"
    assert compare_attrs(group1.attrs, group2.attrs)
    assert group1.dims == group2.dims, f"dims mismatch : {group1.dims} vs {group2.dims}"
    assert set(group1.data_vars) == set(group2.data_vars)
    for name in group1.data_vars.keys():
        assert_dataarray_equal(group1[name], group2[name])
    for sub_g1, sub_g2 in zip(list(group1.children.values()), list(group2.children.values())):
        assert_datatree_distinct_equal(sub_g1, sub_g2)


def assert_eoobject_equal(
    obj1: Union["DataTree", "DataArray"],
    obj2: Union["DataTree", "DataArray"],
    compare_privates_attr=False,
    compare_eop_attrs=True,
    check_history=True,
):
    """Check both objects have the same attributes, and if existing the same data.
    Does not check childs of containers.
    """

    if isinstance(obj1, DataArray):
        if obj1.dtype == np.dtype("complex64"):
            # can be manually checked since NetCDF4 does not support complex64, only related to S1_L1
            assert True
        if obj1.dtype == np.dtype("S128") and obj2.dtype == np.dtype("O"):
            # issue https://gitlab.eopf.copernicus.eu/cpm/eopf-cpm/-/issues/119
            # due to issue https://github.com/pydata/xarray/issues/2059, only related to S1_L1
            assert True
    else:
        attrs1 = obj1.attrs.copy()
        attrs2 = obj2.attrs.copy()

        # the dataset is an attribute used in the conversion process,
        # not an actual attr of the product, case specific for S1 L2
        if "dataset" in attrs2:
            attrs2.pop("dataset")
        if "dataset" in attrs1:
            attrs1.pop("dataset")
        # for slstr l1 and l2 on zarr to safe conversion the eop attrs differ

        # in the case of zarr to safe conversions we do not test the history since this depends on the templates
        if not check_history:
            if "history" in attrs1["other_metadata"]:
                attrs1["other_metadata"].pop("history")
            if "history" in attrs2["other_metadata"]:
                attrs2["other_metadata"].pop("history")

        if isinstance(obj1, DataTree) and compare_eop_attrs:
            np.testing.assert_equal(attrs1, attrs2, verbose=True)

        if isinstance(obj1, DataArray):
            assert isinstance(obj1, DataArray)
            assert_dataarray_equal(obj1, obj2)


def assert_dataarray_equal(variable1: DataArray, variable2: DataArray):
    """Check both variables have the same data."""
    from eopf.common.constants import SCALE_FACTOR

    dask_array = None
    if find_spec("dask") is not None:
        import dask.array as dask_array

    source_data = variable1.data
    target_data = variable2.data
    if dask_array is not None and isinstance(source_data, dask_array.Array):
        source_data = source_data.compute()
    if dask_array is not None and isinstance(target_data, dask_array.Array):
        target_data = target_data.compute()

    # some variable are scalled int (self.scale * int) and can have large atol.
    if SCALE_FACTOR in variable1.attrs:
        variable1_scale = variable1.attrs[SCALE_FACTOR]
    else:
        variable1_scale = None
    if SCALE_FACTOR in variable2.attrs:
        variable2_scale = variable2.attrs[SCALE_FACTOR]
    else:
        variable2_scale = None
    atol = max(variable1_scale or 1.0e-8, variable2_scale or 1.0e-8)
    try:
        if source_data.dtype == np.dtype("datetime64[us]"):
            source_data = source_data.astype("datetime64[s]").astype(np.int32)
        if variable1.is_masked and variable2.is_masked:
            compResult = np.allclose(source_data, target_data, atol=atol)
        else:
            if np.issubdtype(source_data.dtype, np.inexact):
                compResult = np.allclose(source_data, target_data, equal_nan=True, atol=atol)
            else:
                compResult = np.array_equal(
                    source_data,
                    target_data,
                    equal_nan=(source_data.dtype.path_type is not np.bytes_),
                )
        if dask_array is not None and isinstance(compResult, dask_array.Array):
            compResult = compResult.compute()
        assert compResult

    except AssertionError:
        ind = np.where(np.equal(np.isclose(variable1, variable2, equal_nan=True, atol=atol), False))
        for i in ind:
            if np.all(source_data[i] == np.nan) and np.all(target_data[i] == np.nan):
                # all ok, this case should never happen
                print("PASS", i)
            else:
                print("ATTR:", variable1.attrs, variable2.attrs)
                source_data = source_data.compute() if hasattr(source_data, "compute") else source_data
                target_data = target_data.compute() if hasattr(target_data, "compute") else target_data
                print("SOURCE DATA:", source_data, " \n == \n TARGET DATA:", target_data)
                print("ATOL:", atol)

                print("DIFF:", source_data[ind], "==", target_data[ind])
                print("DIFF first:", source_data[i], "==", target_data[i])
                raise


def assert_is_subeocontainer(container1, container2):
    assert type(container1) is type(container2)
    if isinstance(container1, DataArray):
        assert_dataarray_equal(container1, container2)
        return
    for item in container1:
        assert item in container2
        assert_is_subeocontainer(container1[item], container2[item])


def couple_combinaison_from(elements: list[Any]) -> list[tuple[Any, Any]]:
    """create all possible combinaison of two elements from the input list"""
    zip_size = len(elements)
    return sum(
        (list(zip([element] * zip_size, elements)) for element in elements),
        [],
    )


@st.composite
def realize_strategy(draw, to_realize: Union[Any, st.SearchStrategy]):
    if isinstance(to_realize, st.SearchStrategy):
        return draw(to_realize)
    return to_realize


def _glob_to_url(input_dir: str, file_name_pattern: str, protocols: Optional[list[str]] = None, with_protocol=True):
    if protocols is None:
        protocols = []
    protocols.append("file")

    glob_path = os.path.join(input_dir, file_name_pattern)
    matched_files = sorted(glob.glob(glob_path))
    if len(matched_files) == 0:
        logging.exception(f"No files for pattern {file_name_pattern} found in the {input_dir}")
        return ""
    from tests.conftest import TEST_ONLY_ONE_PRODUCT

    protocols_string = f"{'::'.join(protocols)}://" * with_protocol
    if TEST_ONLY_ONE_PRODUCT:
        return [f"{protocols_string}{matched_files[0]}"]
    return [f"{protocols_string}{matched_file}" for matched_file in matched_files]



def glob_fixture(
    glob_pattern: str,
    input_dir: str | None = None,
    protocols: Optional[list[str]] = None,
        with_protocol: bool = True,
    **kwargs: Any,
):
    from tests.conftest import TEST_DATA_PATH

    input_dir = input_dir if input_dir is not None else TEST_DATA_PATH

    def decorator(func):
        @pytest.fixture(scope="session", **kwargs)
        def wrapper():
            matches = _glob_to_url(
                input_dir,
                glob_pattern,
                protocols=protocols,
                with_protocol=with_protocol,
            )
            if not matches:
                raise FileNotFoundError(
                    f"No file found for pattern {glob_pattern!r} in {input_dir!r}",
                )
            if len(matches) > 1:
                raise ValueError(
                    f"Expected exactly one file for pattern {glob_pattern!r}, found {len(matches)}: {matches}",
                )
            return func(matches[0])

        return wrapper

    return decorator
