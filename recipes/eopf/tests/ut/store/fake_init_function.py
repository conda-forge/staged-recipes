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
from copy import copy
from typing import Any, Dict, Optional

import pytest
from xarray import DataArray, DataTree

pytestmark = pytest.mark.dask_only
da = pytest.importorskip("dask.array")

from eopf.common.constants import EOCONTAINER_CATEGORY, EOPRODUCT_CATEGORY, get_product_kind
from eopf.common.file_utils import AnyPath
from eopf.store.mapping_manager import EOPFMappingManager
from eopf.store.safe_reader_helpers import EODataTreeSafeFinalize, EODataTreeSafeInit


class DefaultInitClass(EODataTreeSafeInit):
    def init(self, url, name, attrs, product_type, processing_version, mapping, mapping_manager, **eop_kwargs):
        if get_product_kind(attrs) == EOPRODUCT_CATEGORY:
            return self.init_product(
                url,
                name,
                attrs,
                product_type,
                processing_version,
                mapping,
                mapping_manager,
                **eop_kwargs,
            )
        elif get_product_kind(attrs) == EOCONTAINER_CATEGORY:
            return self.init_container(
                url,
                name,
                attrs,
                product_type,
                processing_version,
                mapping,
                mapping_manager,
                **eop_kwargs,
            )
        raise ValueError("Unhandled product kind")

    def init_product(self, url, name, attrs, product_type, product_version, mapping, mapping_manager, **eop_kwargs):
        eop = DataTree(
            name=name,
        )
        eop.attrs = copy(attrs)
        eop.cpm.product_type = product_type
        eop.cpm.product_kind = EOPRODUCT_CATEGORY
        eop.cpm.processing_version = product_version
        eop["/measurements/image/b01"] = DataArray(
            name="b01_radiance",
            data=da.random.random((1000, 1000), chunks=(100, 100)),
            dims=("x", "y"),
        )
        eop["/measurements/image/b01"] = eop["/measurements/image/b01"].assign_coords(
            coords={"x": range(0, 1000), "y": range(0, 1000)},
        )
        return eop

    def init_container(
        self,
        url: AnyPath,
        name: str,
        attrs: Dict[str, Any],
        product_type: str,
        processing_version: str,
        mapping: Optional[dict[str, Any]],
        mapping_manager: EOPFMappingManager,
        **eop_kwargs: Any,
    ) -> DataTree:
        eop = DataTree(name="p1")
        eop.cpm.product_type = product_type
        eop.cpm.product_kind = EOPRODUCT_CATEGORY
        eop.cpm.processing_version = processing_version
        eop["/measurements/image/b01"] = DataArray(
            name="b01_radiance",
            data=da.random.random((1000, 1000), chunks=(100, 100)),
            dims=("x", "y"),
        )
        eop["/measurements/image/b01"] = eop["/measurements/image/b01"].assign_coords(
            coords={"x": range(0, 1000), "y": range(0, 1000)},
        )

        eoc = DataTree(name=name)
        eoc.cpm.product_type = product_type
        eoc.cpm.product_kind = EOCONTAINER_CATEGORY
        eoc.cpm.processing_version = processing_version
        eoc["p1"] = eop
        print(eoc)
        return eoc


class DefaultFinalizeClass(EODataTreeSafeFinalize):
    def finalize(
        self,
        eop,
        url,
        mapping,
        mapping_manager,
        **eop_kwargs,
    ):
        if eop.cpm.product_kind == EOPRODUCT_CATEGORY:
            return self.finalize_product(
                eop,
                url,
                mapping,
                mapping_manager,
                **eop_kwargs,
            )
        elif eop.cpm.product_kind == EOCONTAINER_CATEGORY:
            return self.finalize_container(
                eop,
                url,
                mapping,
                mapping_manager,
                **eop_kwargs,
            )
        raise ValueError("Unhandled product kind")

    def finalize_product(
        self,
        eop,
        url,
        mapping,
        mapping_manager,
        **eop_kwargs,
    ):
        eop["/measurements/image/b02"] = DataArray(
            name="b02_radiance",
            data=da.random.random((1000, 1000), chunks=(100, 100)),
            dims=("x", "y"),
        )

        # eop["/measurements/image/b01"].assign_dims(("x", "y"))
        eop["/measurements/image/b02"] = eop["/measurements/image/b02"].assign_coords(
            coords={"x": range(0, 1000), "y": range(0, 1000)},
        )
        return eop

    def finalize_container(
        self,
        container: DataTree,
        url: AnyPath,
        mapping: Optional[dict[str, Any]],
        mapping_manager: EOPFMappingManager,
        **eop_kwargs: Any,
    ) -> DataTree:
        container["/p1/measurements/image/b02"] = DataArray(
            name="b02_radiance",
            data=da.random.random((1000, 1000), chunks=(100, 100)),
            dims=("x", "y"),
        )
        container["/p1/measurements/image/b02"] = container["/p1/measurements/image/b02"].assign_coords(
            coords={"x": range(0, 1000), "y": range(0, 1000)},
        )
        return container
