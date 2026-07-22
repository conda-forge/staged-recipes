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
import re
from pathlib import Path

import pytest
from xarray import DataTree

from eopf import EOConfiguration
from eopf.common.constants import EOPF_CPM_PATH
from eopf.exceptions import EOQCConfigMissing, InvalidProductError
from eopf.qualitycontrol.eo_qc_processor import EOQCProcessor


@pytest.fixture
def eoqcProcessorFakeConfig(EMBEDED_TEST_DATA_FOLDER_UNIT):
    qc_processor = EOQCProcessor(
        config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
    )
    return qc_processor


"""
Unit tests

"""


@pytest.mark.unit
def test_EOQCProcessor_init():
    eoqc = EOQCProcessor()
    assert eoqc is not None


@pytest.mark.unit
def test_EOQCProcessor_noproducttype(eoqcProcessorFakeConfig):
    product = DataTree(name="my_product")
    product.product_type = ""
    with pytest.raises(InvalidProductError):
        eoqcProcessorFakeConfig.check(product)


@pytest.mark.unit
def test_EOQCProcessor_wrongproductType(eoqcProcessorFakeConfig):
    product = DataTree(name="my_product")
    product.cpm.product_type = "machinbidule"
    product.cpm.processing_version = "1.0.0"
    with pytest.raises(EOQCConfigMissing):
        eoqcProcessorFakeConfig.check(product)


@pytest.mark.unit
def test_EOQCProcessor_with_replaced(
    fake_quality_repla_product,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    qc_processor = EOQCProcessor(
        config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
        parameters={"V_MIN": 0},
    )
    assert qc_processor is not None
    qc_processor.check(fake_quality_repla_product)


@pytest.mark.unit
def test_EOQCProcessor_with_replaced_error(
    fake_quality_repla_product,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    with pytest.raises(KeyError):
        qc_rocessor = EOQCProcessor(
            config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
            parameters={},
        )
        qc_rocessor.check(fake_quality_repla_product)


@pytest.mark.unit
def test_EOQCProcessor_check(
    fake_quality_datatree,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
    OUTPUT_DIR,
):
    report_folder = Path(os.path.join(OUTPUT_DIR, "reports"))
    report_folder.mkdir(exist_ok=True)
    qc_processor = EOQCProcessor(
        config_folders=[os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")],
        report_folder=report_folder,
        update_attrs=True,
    )
    # assert qc_processor is not None
    res_product = qc_processor.check(fake_quality_datatree)
    assert res_product is not None
    assert "quality" in res_product
    print(res_product.quality.attrs)
    attr_to_check = res_product.quality.attrs
    attr_to_check["qc"]["inspection_date"] = "UTC=2024-12-10T23:17:14"
    assert attr_to_check == {
        "qc": {
            "product_name": "test",
            "product_type": "FAKEONE",
            "processing_version": "1.1.0",
            "qc_config_version": "1.0.0",
            "qc_config_identifier": "FAKEY",
            "inspection_date": "UTC=2024-12-10T23:17:14",
            "global_status": "PASSED",
            "inspections": {
                "fake_inspection": {
                    "identifier": "fake_inspection",
                    "version": "0.0.1",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validate that orbit number is between value",
                    "status": True,
                    "message": "PASSED: Formula v_min < absolute_orbit < v_max evaluate True on the product test",
                },
                "fake_inspection_bis": {
                    "identifier": "fake_inspection_bis",
                    "version": "0.0.1",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validate that orbit number is between value",
                    "status": True,
                    "message": "PASSED: Formula v_min < absolute_orbit < v_max evaluate True on the product test",
                },
                "fake_inspection_ter": {
                    "identifier": "fake_inspection_ter",
                    "version": "0.0.1",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validate that orbit number is between value",
                    "status": True,
                    "message": "PASSED: Formula v_min < absolute_orbit < v_max evaluate True on the product test",
                },
            },
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "relative_orbit": 238,
            "absolute_orbit": 32936,
        },
    }
    assert len(list(report_folder.glob("*json"))) == 1


@pytest.mark.unit
def test_EOQCProcessor_template_check(
    fake_template_product,
    OUTPUT_DIR,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    EOConfiguration().qualitycontrol__folder = Path(EOPF_CPM_PATH) / "qualitycontrol/config/"
    print(EOConfiguration().qualitycontrol__folder)
    report_folder = Path(os.path.join(OUTPUT_DIR, "reports"))
    report_folder.mkdir(exist_ok=True)
    qc_processor = EOQCProcessor(report_folder=report_folder, update_attrs=True)
    assert qc_processor is not None
    res_product = qc_processor.check(fake_template_product)
    EOConfiguration().qualitycontrol__folder = os.path.join(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        "qualitycontrol",
    )
    assert res_product is not None
    assert "quality" in res_product
    print(res_product.quality.attrs)
    attr_to_check = res_product.quality.attrs
    attr_to_check["qc"]["inspection_date"] = "UTC=2024-12-10T23:17:14"
    data_size_inspection = attr_to_check["qc"]["inspections"]["product_data_size"]
    assert re.fullmatch(
        r"PASSED: The product test datasize \(\d+\) is within range \[1048576,10737418240\]",
        data_size_inspection["message"],
    )
    data_size_inspection["message"] = (
        "PASSED: The product test datasize (<bytes>) is within range [1048576,10737418240]"
    )
    print(attr_to_check)
    assert attr_to_check == {
        "qc": {
            "product_name": "test",
            "product_type": "TEMPLATE_PRODUCT_TYPE",
            "processing_version": "1.1.0",
            "qc_config_version": "1.0.0",
            "qc_config_identifier": "TEMPLATE",
            "inspection_date": "UTC=2024-12-10T23:17:14",
            "global_status": "PASSED",
            "inspections": {
                "product_data_size": {
                    "identifier": "product_data_size",
                    "version": "1.0.0",
                    "thematic": "GENERAL_QUALITY",
                    "description": "Evaluate the data size in Bytes for anomaly detection",
                    "status": True,
                    "message": "PASSED: The product test datasize (<bytes>) is within range [1048576,10737418240]",
                },
                "product_attr_size": {
                    "identifier": "product_attr_size",
                    "version": "1.0.0",
                    "thematic": "GENERAL_QUALITY",
                    "description": "Evaluate the attr size in Bytes for anomaly detection",
                    "status": True,
                    "message": "PASSED: The product test attr size (2034) is within range [128,1048576]",
                },
                "validate_product": {
                    "identifier": "validate_product",
                    "version": "1.0.0",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validity product check",
                    "status": True,
                    "message": "PASSED: The product test has valid structure;STAC datetime are valid",
                },
                "absolute_orbit": {
                    "identifier": "absolute_orbit",
                    "version": "1.0.0",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validate that absolute orbit number is between value",
                    "status": True,
                    "message": "PASSED: Formula v_min < absolute_orbit < v_max evaluate True on the product test",
                },
                "relative_orbit": {
                    "identifier": "relative_orbit",
                    "version": "1.0.0",
                    "thematic": "GENERAL_QUALITY",
                    "description": "validate that relative orbit number is between value",
                    "status": True,
                    "message": "PASSED: Formula v_min < relative_orbit < v_max evaluate True on the product test",
                },
            },
            "start_datetime": "2022-06-14T13:00:43.45Z",
            "end_datetime": "2022-06-14T13:12:40.45Z",
            "relative_orbit": 238,
            "absolute_orbit": 32936,
        },
    }
    mandatory_checks = [
        "product_data_size",
        "product_attr_size",
        "validate_product",
        "absolute_orbit",
        "relative_orbit",
    ]
    assert mandatory_checks == list(attr_to_check["qc"]["inspections"].keys())

    assert len(list(report_folder.glob("*json"))) == 1


@pytest.mark.unit
def test_EOQCProcessor_container_check(
    fake_quality_container,
    OUTPUT_DIR,
    EMBEDED_TEST_DATA_FOLDER_UNIT,
):
    EOConfiguration().qualitycontrol__folder = os.path.join(
        EMBEDED_TEST_DATA_FOLDER_UNIT,
        "qualitycontrol",
    )
    print(EOConfiguration().qualitycontrol__folder)
    report_folder = Path(os.path.join(OUTPUT_DIR, "reports_container"))
    report_folder.mkdir(exist_ok=True)
    qc_processor = EOQCProcessor(report_folder=report_folder, update_attrs=True)
    assert qc_processor is not None
    print(fake_quality_container)
    res_product = qc_processor.check(fake_quality_container)
    EOConfiguration().qualitycontrol__folder = EOPF_CPM_PATH / "qualitycontrol/config/"
    assert res_product is not None
    # Should have container, subcontainer and the product report
    print(report_folder)
    assert len(list(report_folder.glob("*json"))) == 3
