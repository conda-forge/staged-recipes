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
from collections.abc import Mapping, Sequence
from typing import Any

import numpy as np
import pytest
from xarray import DataTree

from eopf import open_datatree, write_datatree
from eopf.common.xarray_utils import restore_datatree_attrs_from_netcdf


def _normalize_expected_attr_for_comparison(value: Any) -> Any:
    """
    Normalize original attribute values to match the current NetCDF restore policy.

    This mirrors the best-effort normalization done by:
    - _restore_attr_from_netcdf
    - _normalize_attr

    Notes
    -----
    This is intentionally test-side normalization of the original expected values.
    """
    if value is None:
        return None

    if isinstance(value, np.generic):
        return value.item()

    if isinstance(value, np.ndarray):
        return value

    if isinstance(value, bool):
        return int(value)

    if isinstance(value, tuple):
        return [_normalize_expected_attr_for_comparison(v) for v in value]

    if isinstance(value, Mapping):
        return {k: _normalize_expected_attr_for_comparison(v) for k, v in value.items()}

    if isinstance(value, Sequence) and not isinstance(value, (str, bytes, bytearray)):
        return [_normalize_expected_attr_for_comparison(v) for v in value]

    return value


def _assert_attrs_best_effort_equal(
        expected: Mapping[str, Any],
        actual: Mapping[str, Any],
) -> None:
    """
    Compare two attribute mappings with tolerance for NetCDF round-trip losses.
    """
    assert set(expected) == set(actual), (
        f"Attribute keys differ: expected={set(expected)}, actual={set(actual)}"
    )

    for key in expected:
        expected_value = _normalize_expected_attr_for_comparison(expected[key])
        actual_value = actual[key]

        if isinstance(expected_value, np.ndarray):
            np.testing.assert_equal(
                expected_value,
                actual_value,
                err_msg=f"Mismatch for attr {key!r}",
            )
        else:
            assert actual_value == expected_value, f"Mismatch for attr {key!r}"


def _assert_variable_best_effort_equal(expected_var: Any, actual_var: Any, var_name: str) -> None:
    """
    Compare two xarray variables/dataarrays after NetCDF round-trip.
    """
    assert expected_var.dims == actual_var.dims, f"Mismatch for dims of {var_name!r}"
    assert expected_var.shape == actual_var.shape, f"Mismatch for shape of {var_name!r}"
    assert np.dtype(expected_var.dtype) == np.dtype(actual_var.dtype), (
        f"Mismatch for dtype of {var_name!r}: "
        f"expected={expected_var.dtype}, actual={actual_var.dtype}"
    )

    np.testing.assert_equal(
        expected_var.values,
        actual_var.values,
        err_msg=f"Mismatch for values of {var_name!r}",
    )

    _assert_attrs_best_effort_equal(expected_var.attrs, actual_var.attrs)


def _assert_dataset_best_effort_equal(expected_ds: Any, actual_ds: Any, path: str) -> None:
    """
    Compare two xarray datasets after NetCDF round-trip.
    """
    assert actual_ds is not None, f"Missing dataset at node {path!r}"

    assert dict(expected_ds.sizes) == dict(actual_ds.sizes), (
        f"Mismatch for sizes at node {path!r}: "
        f"expected={dict(expected_ds.sizes)}, actual={dict(actual_ds.sizes)}"
    )

    assert set(expected_ds.variables) == set(actual_ds.variables), (
        f"Mismatch for variables at node {path!r}: "
        f"expected={set(expected_ds.variables)}, actual={set(actual_ds.variables)}"
    )

    assert set(expected_ds.data_vars) == set(actual_ds.data_vars), (
        f"Mismatch for data_vars at node {path!r}: "
        f"expected={set(expected_ds.data_vars)}, actual={set(actual_ds.data_vars)}"
    )

    assert set(expected_ds.coords) == set(actual_ds.coords), (
        f"Mismatch for coords at node {path!r}: "
        f"expected={set(expected_ds.coords)}, actual={set(actual_ds.coords)}"
    )

    _assert_attrs_best_effort_equal(expected_ds.attrs, actual_ds.attrs)

    for var_name in expected_ds.variables:
        _assert_variable_best_effort_equal(
            expected_ds[var_name],
            actual_ds[var_name],
            var_name=var_name,
        )


def _assert_datatree_best_effort_equal(expected: DataTree, actual: DataTree) -> None:
    """
    Compare two DataTrees after NetCDF write/read and attribute restoration.

    This is a best-effort comparison:
    - structure must match exactly
    - datasets/variables/data must match exactly
    - attrs are compared after expected-side normalization
    """
    expected_paths = sorted(node.path for node in expected.subtree)
    actual_paths = sorted(node.path for node in actual.subtree)

    assert actual_paths == expected_paths, (
        f"Mismatch for tree paths: expected={expected_paths}, actual={actual_paths}"
    )

    for path in expected_paths:
        expected_node = expected[path]
        actual_node = actual[path]

        _assert_attrs_best_effort_equal(expected_node.attrs, actual_node.attrs)

        if expected_node.ds is None:
            assert actual_node.ds is None, f"Expected no dataset at node {path!r}"
        else:
            _assert_dataset_best_effort_equal(expected_node.ds, actual_node.ds, path=path)


@pytest.mark.unit
def test_write_then_read_netcdf_datatree(fake_quality_datatree: DataTree, tmp_path) -> None:
    """
    Verify that writing then reading a DataTree through NetCDF preserves
    information as much as possible under the current restore policy.
    """
    output_file = tmp_path / "output.nc"

    write_datatree(fake_quality_datatree, output_file)
    dtree_read = open_datatree(output_file, engine="cpm_netcdf")
    dtree_restored = restore_datatree_attrs_from_netcdf(dtree_read)

    _assert_datatree_best_effort_equal(fake_quality_datatree, dtree_restored)
