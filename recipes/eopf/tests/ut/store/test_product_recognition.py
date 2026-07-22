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

from eopf.store.mapping_factory import EOPFMappingFactory
from eopf.store.mapping_manager import EOPFMappingManager
from eopf.store.safe_reader import EODataTreeSafeReader

pytestmark = pytest.mark.dask_only
dask = pytest.importorskip("dask")
pytest.importorskip("distributed")

@pytest.fixture
def mapping_factory_data_folder(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return EMBEDED_TEST_DATA_FOLDER_UNIT / "store/mapping_factory"


@pytest.mark.need_files
@pytest.mark.unit
def test_recognize_s3_product_with_pr_factory(mapping_factory_data_folder, S3_OL_1_unit):
    """
    Test the product recognition mechanism: this mechanism is used inside the mapping_factory in order to
    recognize the mapping linked to an S3 product by defining a "function_uid" attribute in the "recognition"
    attribute of the mappings. The product recognition factory will pick the right function from the factory
    thanks to the function identifier (function_uid) contained in the mapping, launch the function to see if
    the current mapping matches the input product and then return a boolean according to the result.

    A fake mapping file using the recognition attribute "function_uid" has been created to test the mechanism:
    -> eopf-cpm/tests/data/store/mapping_factory/test_custom_mappings/S03OLCEFR_test.json

    """
    path_to_fake_mapping_file = mapping_factory_data_folder / "test_custom_mappings/S03OLCEFR_test.json"

    # Register the test mapping file in a mapping factory
    my_mapping_factory = EOPFMappingFactory(mapping_path=path_to_fake_mapping_file)

    product = EODataTreeSafeReader().open_datatree(
        S3_OL_1_unit, mapping_manager=EOPFMappingManager(mapping_factory=my_mapping_factory),
    )

    assert product
    assert product.cpm.product_type == "S03OLCERR"
