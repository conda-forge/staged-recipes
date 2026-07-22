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
import uuid

import numpy as np
import pytest
import xarray as xr
from xarray import DataTree

from eopf.common.file_utils import AnyPath
from eopf.store import write_datatree
from eopf.store.fast_zarr_writer import EODataTreeFastZarrWriter
from eopf.store.zarr_reader import EODataTreeZarrReader


@pytest.mark.unit
def test_fast_zarr_write_matches_cpm_zarr_write(tmp_path):
    product = _fast_zarr_reference_product()
    cpm_zarr_path = tmp_path / "cpm.zarr"
    fast_zarr_path = tmp_path / "fast.zarr"
    reader = EODataTreeZarrReader()

    write_datatree(product, cpm_zarr_path, engine="cpm_zarr", zarr_format=2)
    write_datatree(product, fast_zarr_path, engine="fast_zarr", zarr_format=2)

    xr.testing.assert_identical(
        reader.open_datatree(cpm_zarr_path),
        reader.open_datatree(fast_zarr_path),
    )


@pytest.mark.unit
def test_fast_zarr_writer_options_are_keyword_only(tmp_path):
    with pytest.raises(TypeError):
        EODataTreeFastZarrWriter().write(_fast_zarr_reference_product(), tmp_path / "product.zarr", 2)


@pytest.mark.unit
def test_fast_zarr_compute_false_returns_delayed_write(tmp_path):
    import dask.array as da

    product = _fast_zarr_reference_product()
    product["measurements"].ds["measurement"].data = da.from_array(
        product["measurements"].ds["measurement"].data,
        chunks=(2,),
    )
    output_path = tmp_path / "fast-lazy.zarr"
    reader = EODataTreeZarrReader()

    result = write_datatree(product, output_path, engine="fast_zarr", zarr_format=2, compute=False)

    assert result is not None
    assert output_path.exists()
    assert (output_path / "measurements" / "measurement").exists()

    result.compute()

    xr.testing.assert_identical(
        product.compute(),
        reader.open_datatree(output_path, name="product").compute(),
    )


@pytest.mark.unit
def test_fast_zarr_compute_false_consolidates_metadata_after_delayed_write(tmp_path, monkeypatch):
    import dask.array as da
    import zarr

    product = _fast_zarr_reference_product()
    product["measurements"].ds["measurement"].data = da.from_array(
        product["measurements"].ds["measurement"].data,
        chunks=(2,),
    )
    output_path = tmp_path / "fast-lazy-consolidated.zarr"
    consolidate_calls: list[object] = []

    def fake_consolidate_metadata(store):
        consolidate_calls.append(store)

    monkeypatch.setattr(zarr, "consolidate_metadata", fake_consolidate_metadata)

    result = write_datatree(product, output_path, engine="fast_zarr", zarr_format=2, compute=False)

    assert result is not None
    assert consolidate_calls == []

    result.compute()

    assert len(consolidate_calls) == 1


@pytest.mark.unit
def test_fast_zarr_compute_false_propagates_dask_write_failure(tmp_path):
    import dask
    import dask.array as da

    @dask.delayed
    def fail_write():
        raise RuntimeError("delayed write failed")

    product = _fast_zarr_reference_product()
    product["measurements"].ds["measurement"].data = da.from_delayed(
        fail_write(),
        shape=(3,),
        dtype=np.int64,
    )
    output_path = tmp_path / "fast-lazy-failure.zarr"

    result = write_datatree(product, output_path, engine="fast_zarr", zarr_format=2, compute=False)

    assert result is not None
    assert output_path.exists()
    with pytest.raises(RuntimeError, match="delayed write failed"):
        result.compute()


@pytest.mark.unit
def test_fast_zarr_write_by_subdatatree_matches_normal_write(tmp_path):
    product = _fast_zarr_reference_product()
    normal_path = tmp_path / "fast-normal.zarr"
    subdatatree_path = tmp_path / "fast-subdatatree.zarr"
    reader = EODataTreeZarrReader()

    write_datatree(product, normal_path, engine="fast_zarr", zarr_format=2)
    write_datatree(product, subdatatree_path, engine="fast_zarr", zarr_format=2, write_by_subdatatree=True)

    xr.testing.assert_identical(
        reader.open_datatree(normal_path),
        reader.open_datatree(subdatatree_path),
    )


@pytest.mark.unit
def test_fast_zarr_write_by_subdatatree_flushes_each_dask_node(tmp_path, monkeypatch):
    import dask.array as da

    product = DataTree(name="product", dataset=xr.Dataset(attrs={"root_attr": "root"}))
    product["measurements"] = DataTree(
        name="measurements",
        dataset=xr.Dataset({"measurement": ("x", da.from_array(np.array([1, 2, 3]), chunks=(2,)))}),
    )
    product["quality"] = DataTree(
        name="quality",
        dataset=xr.Dataset({"flag": ("x", da.from_array(np.array([0, 1, 0]), chunks=(2,)))}),
    )
    store_calls: list[int] = []
    original_store = da.store

    def recording_store(sources, targets, **kwargs):
        store_calls.append(len(sources))
        return original_store(sources, targets, **kwargs)

    monkeypatch.setattr(da, "store", recording_store)

    write_datatree(product, tmp_path / "fast-subdatatree-dask.zarr", engine="fast_zarr", write_by_subdatatree=True)

    assert store_calls == [1, 1]


@pytest.mark.unit
def test_fast_zarr_write_by_subdatatree_rejects_compute_false(tmp_path):
    with pytest.raises(NotImplementedError, match="write_by_subdatatree does not support compute=False"):
        write_datatree(
            _fast_zarr_reference_product(),
            tmp_path / "fast-subdatatree-lazy.zarr",
            engine="fast_zarr",
            zarr_format=2,
            write_by_subdatatree=True,
            compute=False,
        )


@pytest.mark.unit
@pytest.mark.parametrize("zarr_format", [2, 3], ids=["zarr_v2", "zarr_v3"])
def test_fast_zarr_matches_cpm_zarr_for_zarr_format(tmp_path, zarr_format):
    product = _fast_zarr_reference_product()
    cpm_zarr_path = tmp_path / f"cpm-v{zarr_format}.zarr"
    fast_zarr_path = tmp_path / f"fast-v{zarr_format}.zarr"
    reader = EODataTreeZarrReader()

    write_datatree(product, cpm_zarr_path, engine="cpm_zarr", zarr_format=zarr_format)
    write_datatree(product, fast_zarr_path, engine="fast_zarr", zarr_format=zarr_format)

    xr.testing.assert_identical(
        reader.open_datatree(cpm_zarr_path),
        reader.open_datatree(fast_zarr_path),
    )
    if zarr_format == 2:
        assert (cpm_zarr_path / ".zmetadata").exists()
        assert (fast_zarr_path / ".zmetadata").exists()


@pytest.mark.unit
@pytest.mark.parametrize("zarr_format", [2, 3], ids=["zarr_v2", "zarr_v3"])
def test_fast_zarr_matches_cpm_zarr_with_encoding(tmp_path, zarr_format):
    product = _fast_zarr_reference_product()
    cpm_zarr_path = tmp_path / f"cpm-encoded-v{zarr_format}.zarr"
    fast_zarr_path = tmp_path / f"fast-encoded-v{zarr_format}.zarr"
    reader = EODataTreeZarrReader()
    encoding = {
        "/measurements": {
            "measurement": {
                "chunks": (2,),
                "_FillValue": -1,
            },
        },
    }

    write_datatree(product, cpm_zarr_path, engine="cpm_zarr", zarr_format=zarr_format, encoding=encoding)
    write_datatree(product, fast_zarr_path, engine="fast_zarr", zarr_format=zarr_format, encoding=encoding)

    xr.testing.assert_identical(
        reader.open_datatree(cpm_zarr_path),
        reader.open_datatree(fast_zarr_path),
    )


@pytest.mark.unit
def test_fast_zarr_matches_cpm_zarr_for_many_small_metadata_groups(tmp_path):
    product = DataTree(name="product", dataset=xr.Dataset(attrs={"root_attr": "root"}))
    for index in range(25):
        product[f"group_{index:02d}"] = DataTree(
            name=f"group_{index:02d}",
            dataset=xr.Dataset(
                {"value": xr.DataArray([index], dims=("x",), attrs={"unit": "count"})},
                attrs={"group_index": index},
            ),
        )
    cpm_zarr_path = tmp_path / "cpm-many-groups.zarr"
    fast_zarr_path = tmp_path / "fast-many-groups.zarr"
    reader = EODataTreeZarrReader()

    write_datatree(product, cpm_zarr_path, engine="cpm_zarr", zarr_format=2)
    write_datatree(product, fast_zarr_path, engine="fast_zarr", zarr_format=2)

    xr.testing.assert_identical(
        reader.open_datatree(cpm_zarr_path),
        reader.open_datatree(fast_zarr_path),
    )


@pytest.mark.unit
def test_fast_zarr_rejects_unsupported_xarray_kwargs(tmp_path):
    with pytest.raises(NotImplementedError, match="append_dim"):
        write_datatree(
            _fast_zarr_reference_product(),
            tmp_path / "unsupported.zarr",
            engine="fast_zarr",
            append_dim="x",
        )


@pytest.mark.unit
def test_fast_zarr_rejects_unsupported_write_mode(tmp_path):
    with pytest.raises(NotImplementedError, match="only supports mode"):
        write_datatree(
            _fast_zarr_reference_product(),
            tmp_path / "append.zarr",
            engine="fast_zarr",
            mode="a",
        )


@pytest.mark.unit
def test_fast_zarr_rejects_unsupported_encoding_keys(tmp_path):
    encoding = {
        "/measurements": {
            "measurement": {
                "scale_factor": 0.1,
            },
        },
    }

    with pytest.raises(NotImplementedError, match="scale_factor"):
        write_datatree(
            _fast_zarr_reference_product(),
            tmp_path / "unsupported-encoding.zarr",
            engine="fast_zarr",
            encoding=encoding,
        )


@pytest.mark.unit
@pytest.mark.real_s3
def test_fast_zarr_write_real_s3_with_storage_options(
    s3_output_test_data,
    s3_output_config_real,
):
    protocol, base_path = s3_output_test_data
    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    output_file = f"{run_path}/fast.zarr"

    try:
        write_datatree(
            _fast_zarr_reference_product(),
            output_file,
            engine="fast_zarr",
            zarr_format=2,
            storage_options=s3_output_config_real,
        )
        loaded = EODataTreeZarrReader().open_datatree(
            output_file,
            storage_options=s3_output_config_real,
        )
        assert "measurements" in loaded
    finally:
        output_path = AnyPath(run_path, **s3_output_config_real)
        if output_path.exists():
            output_path.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.xfail(
    reason="Some S3-compatible providers do not support obstore PUT semantics and return 501 Not Implemented",
)
def test_fast_zarr_write_real_s3_obstore(
    s3_output_test_data,
    s3_output_config_real,
):
    protocol, base_path = s3_output_test_data
    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    output_file = f"{run_path}/fast-obstore.zarr"

    try:
        write_datatree(
            _fast_zarr_reference_product(),
            output_file,
            engine="fast_zarr",
            zarr_format=2,
            mode="w",
            storage_options=s3_output_config_real,
            use_obstore=True,
        )
        loaded = EODataTreeZarrReader().open_datatree(
            output_file,
            storage_options=s3_output_config_real,
        )
        assert "measurements" in loaded
    finally:
        output_path = AnyPath(run_path, **s3_output_config_real)
        if output_path.exists():
            output_path.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
def test_fast_zarr_real_s3_overwrite_semantics(
    s3_output_test_data,
    s3_output_config_real,
):
    from zarr.errors import ContainsGroupError

    protocol, base_path = s3_output_test_data
    run_path = f"{protocol}://{base_path}/{uuid.uuid4()}"
    output_file = f"{run_path}/fast-overwrite.zarr"
    product = _fast_zarr_reference_product()

    try:
        write_datatree(
            product,
            output_file,
            engine="fast_zarr",
            zarr_format=2,
            storage_options=s3_output_config_real,
        )
        with pytest.raises((ContainsGroupError, FileExistsError)):
            write_datatree(
                product,
                output_file,
                engine="fast_zarr",
                zarr_format=2,
                mode="w-",
                storage_options=s3_output_config_real,
            )
    finally:
        output_path = AnyPath(run_path, **s3_output_config_real)
        if output_path.exists():
            output_path.rm(recursive=True)


def _fast_zarr_reference_product() -> DataTree:
    product = DataTree(name="product", dataset=xr.Dataset(attrs={"root_attr": "root"}))
    product["measurements"] = DataTree(
        name="measurements",
        dataset=xr.Dataset(
            {
                "measurement": xr.DataArray(
                    [1, 2, 3],
                    dims=("x",),
                    attrs={"units": "count"},
                ),
                "quality": xr.DataArray(
                    [0, 1, 0],
                    dims=("x",),
                    attrs={"flag_meanings": "valid invalid valid"},
                ),
            },
            coords={"x": [10, 20, 30]},
            attrs={"group_attr": "measurements"},
        ),
    )
    return product
