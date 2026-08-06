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
from pathlib import Path
from typing import Any

import pytest
import xarray as xr
from xarray import DataTree

from eopf.common.file_utils import AnyPath
from eopf.store.zarr_reader import EODataTreeZarrReader
from eopf.store.zarr_writer import EODataTreeZarrWriter


@pytest.mark.unit
def test_zarr_write(OUTPUT_DIR, fake_quality_datatree):
    output_file = Path(OUTPUT_DIR) / "olci_zarr_test_output.zarr"

    EODataTreeZarrWriter().write(dtree=fake_quality_datatree, filename_or_obj=output_file)


@pytest.mark.unit
def test_zarr_write_by_subdatatree_rebases_path_encoding():
    product = DataTree(name="product")
    product["measurements"] = DataTree(
        name="measurements",
        dataset=xr.Dataset({"measurement": ("x", [1, 2, 3])}),
    )

    write_kwargs = EODataTreeZarrWriter()._get_node_dataset_write_kwargs(
        filename_or_obj="encoded.zarr",
        node=product["measurements"],
        zarr_format=2,
        encoding={"/measurements": {"measurement": {"chunks": (1,)}}},
        default_codec=None,
    )

    assert write_kwargs["encoding"]["measurement"]["chunks"] == (1,)


@pytest.mark.unit
def test_zarr_write_by_subdatatree_matches_normal_write(tmp_path):
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
            },
            attrs={"group_attr": "measurements"},
        ),
    )
    product["quality"] = DataTree(
        name="quality",
        dataset=xr.Dataset(
            {
                "flag": xr.DataArray(
                    [True, False, True],
                    dims=("x",),
                    attrs={"flag_meanings": "valid invalid valid"},
                ),
            },
            attrs={"group_attr": "quality"},
        ),
    )
    writer = EODataTreeZarrWriter()
    reader = EODataTreeZarrReader()
    normal_path = tmp_path / "normal.zarr"
    subdatatree_path = tmp_path / "subdatatree.zarr"

    writer.write(product, normal_path, zarr_format=2)
    writer.write(product, subdatatree_path, zarr_format=2, write_by_subdatatree=True)

    xr.testing.assert_identical(
        reader.open_datatree(normal_path),
        reader.open_datatree(subdatatree_path),
    )


@pytest.mark.unit
def test_zarr_write_by_subdatatree_rejects_compute_false(tmp_path):
    with pytest.raises(NotImplementedError, match="write_by_subdatatree does not support compute=False"):
        EODataTreeZarrWriter().write(
            DataTree(name="product", dataset=xr.Dataset({"value": ("x", [1])})),
            tmp_path / "subdatatree-lazy.zarr",
            zarr_format=2,
            write_by_subdatatree=True,
            compute=False,
        )


@pytest.mark.unit
@pytest.mark.real_s3
def test_zarr_write_s3(OUTPUT_DIR, fake_quality_datatree, s3_output_test_data, s3_output_config_real):
    protocol, base_path = s3_output_test_data
    output_file = f"{protocol}://{base_path}/{str(uuid.uuid4())}/olci_zarr_test_output.zarr"

    EODataTreeZarrWriter().write(
        dtree=fake_quality_datatree,
        filename_or_obj=output_file,
        storage_options=s3_output_config_real,
    )

    AnyPath(output_file, **s3_output_config_real).rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
def test_zarr_write_s3_obstore(
    OUTPUT_DIR, fake_quality_datatree, s3_output_test_data, obstore_s3_output_config_real,
    s3_output_config_real,
):
    """
    Should fail on OVH

    Parameters
    ----------
    OUTPUT_DIR
    fake_quality_datatree
    s3_output_test_data
    obstore_s3_output_config_real
    s3_output_config_real

    Returns
    -------

    """
    from obstore.store import S3Store
    from zarr.storage import ObjectStore

    protocol, base_path = s3_output_test_data
    output_file = f"{protocol}://{base_path}/{str(uuid.uuid4())}/olci_zarr_test_output.zarr"
    AnyPath(output_file, **s3_output_config_real).mkdir(exist_ok=True)
    store = S3Store.from_url(output_file, config=obstore_s3_output_config_real)

    try:
        EODataTreeZarrWriter().write(
            dtree=fake_quality_datatree,
            filename_or_obj=ObjectStore(store),
            mode="w",
        )
    except Exception as e:
        pytest.xfail(f"Conditional PUT not supported by backend: {e}")
    finally:
        AnyPath(output_file, **s3_output_config_real).rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.asyncio
async def test_obstore_conditional_put_support(
        s3_output_test_data,
        s3_output_config_real,
        obstore_s3_output_config_real,
):
    """
    Validate whether the backend supports conditional PUT (mode="create").

    Expected:
    - plain PUT works
    - conditional PUT may fail with 501 on some S3-compatible backends (e.g. OVH)
    """

    import obstore as obs
    from obstore.store import S3Store

    protocol, base_path = s3_output_test_data

    # --- Unique prefix for isolation ---
    test_id = str(uuid.uuid4())
    output_file = f"{protocol}://{base_path}/test_conditional_put/{test_id}/"

    # Ensure folder exists (for compatibility with your existing infra)
    AnyPath(output_file, **s3_output_config_real).mkdir(exist_ok=True)

    store = S3Store.from_url(
        output_file,
        config=obstore_s3_output_config_real,
    )

    try:
        # --- Plain PUT (should always work) ---
        await obs.put_async(store, "plain.txt", b"ok")

        # --- Conditional PUT ---
        try:
            await obs.put_async(store, "create.txt", b"ok", mode="create")
        except Exception as e:
            pytest.xfail(f"Conditional PUT not supported by backend: {e}")

    finally:
        # --- Cleanup (best effort) ---
        # Remove created objects to avoid polluting bucket
        import contextlib

        for key in ("plain.txt", "create.txt"):
            with contextlib.suppress(Exception):
                await obs.delete_async(store, key)


@pytest.mark.real_s3
@pytest.mark.unit
def test_write_real_s3(
    dask_context,
    s3_test_data: tuple[str | None, str],
    s3_output_test_data: tuple[str | None, str],
    s3_config_real: dict[str, Any],
    s3_output_config_real: dict[str, Any],
) -> None:
    in_protocol, in_base_path = s3_test_data
    out_protocol, out_base_path = s3_output_test_data

    if in_protocol is None:
        raise RuntimeError("S3_TEST_DATA_FOLDER must include a protocol")
    if out_protocol is None:
        raise RuntimeError("S3_OUTPUT_TEST_DATA_FOLDER must include a protocol")

    w_path = f"{out_protocol}://{out_base_path}/{uuid.uuid4()}"
    out_path = AnyPath(w_path, **s3_output_config_real)

    try:
        in_path = f"{in_protocol}://{in_base_path}/olci_zarr_test.zarr"
        assert AnyPath(in_path, **s3_config_real).exists()

        eop = EODataTreeZarrReader().open_datatree(
            in_path,
            storage_options=s3_config_real,
        )

        out_path.mkdir(exist_ok=True)
        out_filename = f"{w_path}/olci_zarr_test_cpy.zarr"

        EODataTreeZarrWriter().write(
            eop,
            out_filename,
            storage_options=s3_output_config_real,
            encoding={},
        )

        assert (out_path / "olci_zarr_test_cpy.zarr").exists() is True
    finally:
        if out_path.exists():
            out_path.rm(recursive=True)
