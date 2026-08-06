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
from copy import deepcopy

import pytest
from xarray import DataTree

from eopf import __version__
from eopf.common.constants import (
    EOCONTAINER_CATEGORY,
    EOPRODUCT_CATEGORY,
    PROCESSING_HISTORY_FACILITY_FIELD,
    PROCESSING_HISTORY_INPUTS_FIELD,
    PROCESSING_HISTORY_MANDATORY_FIELDS,
    PROCESSING_HISTORY_OPTIONAL_FIELDS,
    PROCESSING_HISTORY_OUTPUTS_FIELD,
    PROCESSING_HISTORY_PROCESSOR_FIELD,
    PROCESSING_HISTORY_VERSION_FIELD,
)
from eopf.config import EOConfiguration
from eopf.exceptions.errors import ProcessingHistoryError
from eopf.product import history_utils

TEST_ATTRS = {
    "stac_discovery": {},
    "other_metadata": {},
    "processing_history": {
        "Level-1 Product": [
            {
                "processor": "L1.2 processor",
                "version": "2.2",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:15:43.459284Z",
                "inputs": ["SXX_L1-1.SAFE"],
                "outputs": ["SXX_L1-2.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
            {
                "processor": "L1.1 processor",
                "version": "2.2",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:10:43.459284Z",
                "inputs": ["SXX_L0.SAFE"],
                "outputs": ["SXX_L1-1.SAFE"],
                "adfs": ["ADF_L1.SAFE"],
            },
        ],
        "Level-0 Product": [
            {
                "processor": "L0 processor",
                "version": "2.1",
                "facility": "ESA-ESRIN",
                "time": "2022-06-14T13:03:43.459284Z",
                "inputs": ["sat_data.SAFE"],
                "outputs": ["SXX_L0.SAFE"],
                "adfs": ["ADF_L0.SAFE"],
            },
        ],
    },
}


@pytest.mark.filterwarnings("ignore:")
@pytest.mark.unit
def test_get_history():
    prod_name = "test"
    eop = DataTree(name=prod_name)
    eop.attrs = deepcopy(TEST_ATTRS)
    print(eop.attrs)
    eop.cpm.product_kind = EOPRODUCT_CATEGORY
    eop.cpm.sort_attributes()
    # Sort the processing history first
    eop.cpm.sort_processing_history()
    expected_history = deepcopy(eop.attrs["processing_history"])
    print(eop.attrs)
    # EOProduct tests
    # test retrieve entire history
    assert history_utils.get_history(eop)[prod_name] == expected_history

    # test retrieve a level
    assert history_utils.get_history(eop, level_id=-1)[prod_name] == expected_history["Level-1 Product"]
    assert history_utils.get_history(eop, level_id="Level-1 Product")[prod_name] == expected_history["Level-1 Product"]
    assert history_utils.get_history(eop, level_id="Level-4 Product") is None
    assert history_utils.get_history(eop, level_id=8) is None

    # test retrieve an entry
    assert (
        history_utils.get_history(eop, level_id=-1, entry_id=-1)[prod_name]
        == expected_history["Level-1 Product"][-1]
    )
    assert (
        history_utils.get_history(eop, level_id=-1, entry_id="L1.2 processor")[prod_name]
        == expected_history["Level-1 Product"][-1]
    )
    assert history_utils.get_history(eop, level_id=-1, entry_id=-3) is None
    assert history_utils.get_history(eop, level_id=-1, entry_id="L1.7 processor") is None

    # EOContainer tests
    eoc = DataTree(name="root")
    eoc.cpm.product_kind = EOCONTAINER_CATEGORY
    eoc["left1"] = DataTree(name="left1")
    eoc["left1"].cpm.product_kind = EOCONTAINER_CATEGORY
    eoc["left1"]["left2"] = DataTree(name="left2")
    eoc["left1"]["left2"].cpm.product_kind = EOCONTAINER_CATEGORY
    eoc["left1"]["left2"]["test"] = eop
    eoc["right1"] = DataTree(name="right1")
    eoc["right1"].cpm.product_kind = EOCONTAINER_CATEGORY
    eoc["right1"]["test"] = eop
    expected_result = {
        "root/left1/left2/test": expected_history,
        "root/right1/test": expected_history,
    }
    assert history_utils.get_history(eoc) == expected_result
    expected_result = {
        "root/right1/test": expected_history,
    }
    assert history_utils.get_history(eoc, eop_id="right") == expected_result


@pytest.mark.unit
def test_extend_history():

    prod_name = "test"
    eop = DataTree(name=prod_name)
    eop.attrs = deepcopy(TEST_ATTRS)
    eop.cpm.product_kind = EOPRODUCT_CATEGORY

    # test EOProduct
    # test add entry to latest level
    new_l13_entry = {
        "processor": "L1.3 processor",
        "version": "2.2",
        "facility": "ESA-ESRIN",
        "time": "2022-06-14T13:20:43.459284Z",
        "inputs": ["SXX_L1-2.SAFE"],
        "outputs": ["SXX_L1-3.SAFE"],
        "adfs": ["ADF_L1.SAFE"],
    }
    history_utils.extend_history(eop, new_l13_entry)
    assert history_utils.get_history(eop, -1, -1)[prod_name] == new_l13_entry

    # test add entry to a new level
    new_level_name = "Level-2 Product"
    new_l2_entry = {
        "processor": "L2 processor",
        "version": "11.0",
        "facility": "ESA-ESRIN",
        "time": "2022-06-14T13:25:43.459284Z",
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
    }
    history_utils.extend_history(eop, new_l2_entry, new_level_name)
    assert history_utils.get_history(eop, level_id=-1)[prod_name] == [new_l2_entry]

    # test adding an entry to a level that already exists
    with pytest.raises(ProcessingHistoryError):
        # test add entry to a new level
        new_level_name = "Level-2 Product"
        new_l2_entry = {
            "processor": "L2 processor",
            "version": "11.0",
            "facility": "ESA-ESRIN",
            "time": "2022-06-14T13:25:43.459284Z",
            "inputs": ["SXX_L1-3.SAFE"],
            "outputs": ["SXX_L2.SAFE"],
            "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
        }
        history_utils.extend_history(eop, new_l2_entry, new_level_name)
        assert history_utils.get_history(eop, level_id=-1)[prod_name] == [new_l2_entry]

    # test adding an invalid entry, invalid data type
    with pytest.raises(ProcessingHistoryError):
        # test add entry to a new level
        new_level_name = "Level-3 Product"
        new_l2_entry = {
            "processor": "L2 processor",
            "version": 11.0,  # must be a str not a float
            "facility": "ESA-ESRIN",
            "time": "2022-06-14T13:25:43.459284Z",
            "inputs": ["SXX_L1-3.SAFE"],
            "outputs": ["SXX_L2.SAFE"],
            "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
        }
        history_utils.extend_history(eop, new_l2_entry, new_level_name)
        assert history_utils.get_history(eop, level_id=-1)[prod_name] == [new_l2_entry]

    # test adding an invalid level name
    with pytest.raises(ProcessingHistoryError):
        # test add entry to a new level
        new_level_name = "Leve-4 Product"  # wrong level
        new_l2_entry = {
            "processor": "L2 processor",
            "version": "11.0",
            "facility": "ESA-ESRIN",
            "time": "2022-06-14T13:25:43.459284Z",
            "inputs": ["SXX_L1-3.SAFE"],
            "outputs": ["SXX_L2.SAFE"],
            "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
        }
        history_utils.extend_history(eop, new_l2_entry, new_level_name)
        assert history_utils.get_history(eop, level_id=-1)[prod_name] == [new_l2_entry]


@pytest.mark.unit
def test_check_history_entry():

    # test adding an invalid entry, missing mandatory field (time)
    new_entry = {
        "processor": "L2 processor",
        "version": "11.0",
        "facility": "ESA-ESRIN",
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
    }
    ok, message = history_utils.check_history_entry(new_entry)
    assert ok is False

    # test adding an invalid entry, invalid data type on top level dict
    new_entry = {
        "processor": "L2 processor",
        "version": 11.0,  # must be a str not a float
        "facility": "ESA-ESRIN",
        "time": "2022-06-14T13:25:43.459284Z",
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
    }
    ok, _ = history_utils.check_history_entry(new_entry)
    assert ok is False

    # test adding an invalid entry, invalid data type embedded deep in the history
    new_entry = {
        "processor": "L2 processor",
        "version": "11.0",
        "facility": "ESA-ESRIN",
        "time": "2022-06-14T13:25:43.459284Z",
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
        "eopf_cpm_version": "3",
        "eopf_asgard_version": "3",
        "eopf_python_version": "3",
        "execution_parameters": {"param1": 2, "param2": "6"},  # this should be a string
        "something": ["test", "test"],
    }
    ok, msg = history_utils.check_history_entry(new_entry)
    assert ok is False

    # test adding an invalid entry, invalid time
    new_entry = {
        "processor": "L2 processor",
        "version": "11.0",
        "facility": "ESA-ESRIN",
        "time": "x",  # must be a time convertable data
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
    }
    ok, _ = history_utils.check_history_entry(new_entry)
    assert ok is False

    # test adding a valid entry
    new_entry = {
        "processor": "L2 processor",
        "version": "11.0",
        "facility": "ESA-ESRIN",
        "time": "2022-06-14T13:25:43.459284Z",
        "inputs": ["SXX_L1-3.SAFE"],
        "outputs": ["SXX_L2.SAFE"],
        "adfs": ["ADF_L2A.SAFE", "ADF_L2B.SAFE"],
        "eopf_cpm_version": "3",
        "eopf_asgard_version": "3",
        "eopf_python_version": "3",
        "execution_parameters": {"param1": "2", "param2": "6"},
        "something": ["test", "test"],
    }
    ok, msg = history_utils.check_history_entry(new_entry)
    assert ok is True


@pytest.mark.unit
def test_add_eopf_cpm_entry_to_history():

    prod_name = "test"
    eop = DataTree(name=prod_name)
    eop.attrs = deepcopy(TEST_ATTRS)
    eop.cpm.product_kind = EOPRODUCT_CATEGORY
    history_utils.add_eopf_cpm_entry_to_history(
        eop,
        "SOME_INPUT.SAFE",
        "SOME_OUTPUT.SAFE",
    )
    added_entry = history_utils.get_history(eop, -1, -1)
    assert added_entry[prod_name][PROCESSING_HISTORY_PROCESSOR_FIELD] == EOConfiguration().get("general__title")
    assert added_entry[prod_name][PROCESSING_HISTORY_VERSION_FIELD] == __version__
    assert added_entry[prod_name][PROCESSING_HISTORY_FACILITY_FIELD] == EOConfiguration().get("general__facility")
    assert added_entry[prod_name][PROCESSING_HISTORY_INPUTS_FIELD] == [
        "SOME_INPUT.SAFE",
    ]
    assert added_entry[prod_name][PROCESSING_HISTORY_OUTPUTS_FIELD] == [
        "SOME_OUTPUT.SAFE",
    ]


@pytest.mark.unit
def test_add_init_history_entry():
    # test add entry with only mandatory attributes
    new_entry = history_utils.init_history_entry()
    for field in PROCESSING_HISTORY_MANDATORY_FIELDS:
        assert field in new_entry

    # test add all fields
    new_entry = history_utils.init_history_entry(
        add_adfs_field=True,
        add_cpm_version_field=True,
        add_asgard_version_field=True,
        add_python_version_field=True,
        add_processing_parameters_field=True,
    )
    for field in PROCESSING_HISTORY_MANDATORY_FIELDS:
        assert field in new_entry
    for field in PROCESSING_HISTORY_OPTIONAL_FIELDS:
        assert field in new_entry
