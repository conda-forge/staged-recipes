from importlib.util import find_spec

import pytest


pytestmark = [
    pytest.mark.no_dask,
    pytest.mark.skipif(find_spec("dask") is not None, reason="requires dask to be absent"),
]


def test_dask_helpers_import_without_dask() -> None:
    from eopf.dask_utils import dask_helpers

    assert dask_helpers.get_distributed_client() is None
    assert dask_helpers.is_distributed() is False
    assert dask_helpers.scatter("value") == "value"
    assert [future.result() for future in dask_helpers.compute([1, 2])] == [1, 2]


def test_dask_context_is_not_exported_from_package_without_dask() -> None:
    with pytest.raises(ImportError):
        from eopf.dask_utils import DaskContext  # noqa: F401


def test_dask_context_manager_requires_dask_when_imported_explicitly() -> None:
    with pytest.raises(ModuleNotFoundError, match="dask"):
        from eopf.dask_utils.dask_context_manager import DaskContext  # noqa: F401


def test_zarr_read_defaults_do_not_request_dask_chunks_without_dask() -> None:
    from eopf.common.xarray_utils import get_xarray_zarr_read_kwargs

    assert get_xarray_zarr_read_kwargs(filename_or_obj="dummy.zarr")["chunks"] is None
    assert get_xarray_zarr_read_kwargs(filename_or_obj="dummy.zarr", chunks="auto")["chunks"] == "auto"
