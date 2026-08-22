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
import os
from tempfile import TemporaryDirectory

import numpy as np
import pytest
import zarr
from numpy import arange
from xarray import DataArray, DataTree

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")

from eopf.store.zarr_reader import EODataTreeZarrReader
from eopf.store.zarr_writer import EODataTreeZarrWriter


@pytest.mark.unit
def test_datetime64_encoding():
    """
    Test wether datetime64 variables are correctly encoded and decoded when written the xarray
    """
    output_directory = TemporaryDirectory()
    filename = os.path.join(output_directory.name, "eo_data.zarr")
    eo_data = DataTree(name="")
    eo_data["measurements"] = DataTree()
    data = da.from_array(arange(1000).astype("datetime64[ns]"), chunks=100)
    reference_eov = DataArray(data=data, dims="x")
    eo_data["measurements/time"] = reference_eov
    EODataTreeZarrWriter().write(dtree=eo_data, filename_or_obj=filename)

    # test by loading the DataTree

    st = EODataTreeZarrReader().open_datatree(filename_or_obj=filename)
    eo_product = st.load()
    assert eo_product.measurements.time.data.dtype == reference_eov.data.dtype

    # test by retrieving the individual variable
    st2 = EODataTreeZarrReader().open_datatree(filename_or_obj=filename)
    eov_from_zarr = st2.load()["measurements/time"]
    assert eov_from_zarr.data.dtype == reference_eov.data.dtype

    output_directory.cleanup()


@pytest.mark.unit
def test_write_product_to_zarr_folder(dask_context, OUTPUT_DIR):
    # Build custom product
    product = DataTree(name="MY_CUSTOM_PRODUCT")
    product["/measurements/group1"] = DataTree(
        name="group1",
    )
    product.measurements["group1"]["variable_a"] = DataArray("variable_a")

    product["/measurements/group1/group2/variable_b"] = DataArray("group2/variable_b")
    product["/measurements/group1"]["group2"]["/measurements/group1/group2/variable_c"] = DataArray(
        name="/measurements/group1/group2/variable_c",
        data=np.array([[1, 2, 3], [4, 5, 6]]),
        dims=("c1", "c2"),
    )

    # Set custom short names
    ref_short_names = {
        "var_a": "measurements/group1/variable_a",
        "var_b": "measurements/group1/group2/variable_b",
        "var_c": "measurements/group1/group2/variable_c",
    }
    product.cpm.short_names = ref_short_names

    out_name = "test_write_custom_product.zarr"
    EODataTreeZarrWriter().write(product, os.path.join(OUTPUT_DIR, out_name))

    ds = zarr.open(os.path.join(OUTPUT_DIR, out_name))
    # TODO update short_names test after short name refactor
    # assert ds.measurements.group1.variable_a.attrs["eov_attrs"].get("short_name") == "var_a"
    # assert ds.measurements.group1.group2.variable_b.attrs["eov_attrs"].get("short_name") == "var_b"
    # assert ds.measurements.group1.group2.variable_c.attrs["eov_attrs"].get("short_name") == "var_c"

    # # check the short name is not present in variable attributes
    # for key in ref_short_names:
    #     assert SHORT_NAME in product[key].attrs

    assert isinstance(ds["measurements"]["group1"]["variable_a"], zarr.Array)
    assert isinstance(ds["measurements"]["group1"]["group2"]["variable_b"], zarr.Array)
    assert isinstance(ds["measurements"]["group1"]["group2"]["variable_c"], zarr.Array)
    newt = EODataTreeZarrReader().open_datatree(filename_or_obj=os.path.join(OUTPUT_DIR, out_name))
    assert newt
