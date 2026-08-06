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

import pytest
from xarray import DataArray

from eopf.store.mapping_factory import EOPFMappingFactory
from eopf.store.mapping_manager import EOPFMappingManager
from eopf.store.safe_reader import EODataTreeSafeReader

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")
##########################################################################################
# run specific test using keyword search feature of pytest, with logical expresions, ex:
# python3.9 -m pytest test_safe_store_mappings.py::test_convert_safe_mapping -k "S2 and zarr"
##########################################################################################


@pytest.fixture
def custom_safe_mapping(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "custom_mappings", "simple_mapping_file_v1.0.0.json")


@pytest.fixture
def custom_safe_container_mapping(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "custom_mappings", "simple_mapping_container_file_v1.0.0.json")


@pytest.fixture
def from_legacy_attr_mapping(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "custom_mappings", "from_legacy_attr_v1.0.0.json")


@pytest.fixture
def custom_transformer_mapping(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "custom_mappings", "transformer_test_mapping_file_v1.0.0.json")


@pytest.fixture
def custom_sen3_product(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "custom_mappings", "test_product.SEN3")


@pytest.mark.unit
def test_legacy_attr_retrieval(from_legacy_attr_mapping, custom_sen3_product):
    my_mapping_factory = EOPFMappingFactory()
    my_mapping_factory.register_mapping(from_legacy_attr_mapping)

    my_mapping_manager = EOPFMappingManager(mapping_factory=my_mapping_factory)
    product = EODataTreeSafeReader().open_datatree(
        filename_or_obj=custom_sen3_product,
        mapping_manager=my_mapping_manager,
    )
    assert product is not None
    # test variable for which legacy attr were retrieved is in the EOProduct
    assert product["/conditions/meteo/total_ozone"] is not None

    # compare attr between legacy and eopf
    eop_attr = product["/conditions/meteo/total_ozone"].attrs["units"]
    import netCDF4 as nc

    legacy_file = os.path.join(custom_sen3_product, "tie_meteo.nc")
    nds = nc.Dataset(legacy_file)
    legacy_attr = nds["total_ozone"].units
    nds.close()
    assert eop_attr == legacy_attr


def test_transfomer_mapping_scaled(custom_transformer_mapping, custom_sen3_product):
    """
    Test realistic transformer operations in one mapping, when scalling is applied
    """
    import numpy as np

    my_mapping_factory = EOPFMappingFactory()
    my_mapping_factory.register_mapping(custom_transformer_mapping)

    my_mapping_manager = EOPFMappingManager(mapping_factory=my_mapping_factory)
    product = EODataTreeSafeReader().open_datatree(
        filename_or_obj=custom_sen3_product, mapping_manager=my_mapping_manager, mask_and_scale=True,
    )

    # test EOProduct was created
    assert product is not None
    # test variable total_ozone was created under conditions/meteo/
    assert isinstance(product["conditions/meteo/total_ozone"], DataArray)
    eov = product["conditions/meteo/total_ozone"]

    # dimensions transformer
    # test dimensions are tp_rows, tp_columns
    assert eov.dims == ("tp_rows", "tp_columns")
    # coords assignment depends on dimensions
    assert "tp_latitude" in eov.coords
    assert "tp_longitude" in eov.coords

    # masking
    # test valid_max is set as an attribute
    assert eov.attrs["valid_max"] == 100.0
    # test valid_min is set as an attribute
    assert eov.attrs["valid_min"] == 0.0
    # test fill_value is set as an attribute
    assert eov.attrs["fill_value"] == -1.0
    # test eopf_is_masked is set to True
    assert eov.attrs["eopf_is_masked"] is True

    # scalling
    # the variable should be set to eopf_is_scaled since we have eopf_target_dtype set
    assert eov.attrs["eopf_is_scaled"] is True
    # assert eov.dtype equals eopf_target_dtype
    assert np.dtype(eov.dtype).str == eov.attrs["eopf_target_dtype"]
    # eopf_target_dtype automatically inferred based on scale_factor
    assert eov.coords["tp_longitude"].dtype.str == "<f8"
    assert eov.coords["tp_longitude"].attrs["eopf_target_dtype"] == "<f8"
    # eov.dtype as set by eopf_target_dtype
    assert eov.coords["tp_latitude"].dtype.str == "<f4"
    assert eov.coords["tp_latitude"].attrs["eopf_target_dtype"] == "<f4"

    # attributes transformer
    assert eov.attrs["long_name"] == "total columnar ozone content"
    assert eov.attrs["standard_name"] == "atmosphere_mass_content_of_ozone"
    assert eov.attrs["units"] == "kg.m-2"
    assert eov.attrs["dtype"] == "<f4"

    # rechunk transformer
    assert eov.chunks == ((25, 25), (25, 25))


@pytest.mark.unit
def test_transformer_mapping_unscaled(custom_transformer_mapping, custom_sen3_product):
    """
    Test realistic transformer operations in one mapping whn scalling is not applies
    """
    import numpy as np

    my_mapping_factory = EOPFMappingFactory()
    my_mapping_factory.register_mapping(custom_transformer_mapping)

    my_mapping_manager = EOPFMappingManager(mapping_factory=my_mapping_factory)
    product = EODataTreeSafeReader().open_datatree(
        filename_or_obj=custom_sen3_product, mapping_manager=my_mapping_manager,
    )

    # test EOProduct was created
    assert product is not None
    # test variable total_ozone was created under conditions/meteo/
    assert isinstance(product["conditions/meteo/total_ozone"], DataArray)
    eov = product["conditions/meteo/total_ozone"]
    print(eov)

    # masking
    # in case mask is not applied attributes should be also under eov.data.attrs
    # test valid_max is set as an attribute
    assert eov.attrs["valid_max"] == 100.0
    # test valid_min is set as an attribute
    assert eov.attrs["valid_min"] == 0.0
    # test _FillValue is set as an attribute ( xarray version )
    assert eov.attrs["_FillValue"] == -1.0
    # test eopf_is_masked is set to True
    assert "eopf_is_masked" not in eov.attrs

    # scalling
    # variable should not be marked as scaled
    assert "eopf_is_scaled" not in eov.attrs
    # assert eov.dtype equals dtype attr
    assert np.dtype(eov.dtype).str == eov.attrs["dtype"]
    # eov.dtype as set by dtype attr
    assert eov.coords["tp_latitude"].dtype.str == "<i4"
    # eopf_target_dtype should set into attrs even if the scalling is not done
    assert eov.coords["tp_latitude"].attrs["eopf_target_dtype"] == "<f4"

    # attributes transformer
    assert eov.attrs["long_name"] == "total columnar ozone content"
    assert eov.attrs["standard_name"] == "atmosphere_mass_content_of_ozone"
    assert eov.attrs["units"] == "kg.m-2"
    assert eov.attrs["dtype"] == "<f4"


@pytest.mark.unit
def test_custom_mapping(custom_safe_mapping, custom_sen3_product):
    my_mapping_factory = EOPFMappingFactory()
    my_mapping_factory.register_mapping(custom_safe_mapping)

    my_mapping_manager = EOPFMappingManager(mapping_factory=my_mapping_factory)
    product = EODataTreeSafeReader().open_datatree(
        filename_or_obj=custom_sen3_product,
        mapping_manager=my_mapping_manager,
    )
    assert product is not None
    # Added by init function in tests.store.fake_init_function
    assert product["/measurements/image/b01"] is not None
    # added by finalize function in tests.store.fake_init_function
    assert product["/measurements/image/b02"] is not None


@pytest.mark.unit
def test_custom_container_mapping(custom_safe_container_mapping, custom_sen3_product):
    my_mapping_factory = EOPFMappingFactory()
    my_mapping_factory.register_mapping(custom_safe_container_mapping)

    my_mapping_manager = EOPFMappingManager(mapping_factory=my_mapping_factory)
    container = EODataTreeSafeReader().open_datatree(
        filename_or_obj=custom_sen3_product,
        mapping_manager=my_mapping_manager,
    )
    assert container is not None
    print(container.attrs)
    # Added by init function in tests.store.fake_init_function
    assert "p1" in container
    # added by finalize function in tests.store.fake_init_function
    print(container)
    assert container["/p1/measurements/image/b02"] is not None
