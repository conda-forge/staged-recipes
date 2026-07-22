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

from eopf.exceptions.errors import StoreLoadFailure, StoreReadFailure
from eopf.product.product_stac_convention import StacProductConvention
from eopf.store.safe_reader import EODataTreeSafeReader

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")


@pytest.mark.need_files
@pytest.mark.unit
def test_safe_read(S2_MSIL2A_unit):
    store = EODataTreeSafeReader().open_datatree(filename_or_obj=S2_MSIL2A_unit)
    product = store.load()
    assert product is not None
    assert product.cpm.processing_version == "1.0.0"
    assert StacProductConvention.processing_software(product) is not None


@pytest.mark.unit
def test_safe_reader_rejects_non_stac_convention(monkeypatch):
    class DummyConvention:
        pass

    monkeypatch.setattr(
        "eopf.store.safe_reader.get_product_convention",
        lambda: DummyConvention,
    )

    with pytest.raises(StoreLoadFailure, match="requires StacProductConvention"):
        EODataTreeSafeReader().open_datatree(filename_or_obj="dummy.SAFE")


@pytest.mark.unit
def test_safe_reader_accepts_stac_convention(monkeypatch):
    monkeypatch.setattr(
        "eopf.store.safe_reader.get_product_convention",
        lambda: StacProductConvention,
    )
    monkeypatch.setattr(EODataTreeSafeReader, "guess_can_open", lambda self, *_args, **_kwargs: False)

    with pytest.raises(StoreReadFailure, match="can not read product"):
        EODataTreeSafeReader().open_datatree(filename_or_obj="dummy.SAFE")
