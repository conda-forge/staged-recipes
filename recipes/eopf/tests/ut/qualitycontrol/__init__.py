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
from dataclasses import dataclass

import pytest
from xarray import DataTree

from eopf.computing import AuxiliaryDataFile
from eopf.qualitycontrol.eo_qc import EOQC, EOQCPartialCheckResult


@dataclass
class QC01(EOQC):
    threshold: int
    param_2: int
    adf_probas: AuxiliaryDataFile

    def _check(
        self,
        eoproduct: DataTree,
    ) -> EOQCPartialCheckResult:
        return EOQCPartialCheckResult(message="OK", status=True)


@pytest.fixture
def config_folder(EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol")


@pytest.fixture
def sample_config_path(config_folder, EMBEDED_TEST_DATA_FOLDER_UNIT):
    return os.path.join(EMBEDED_TEST_DATA_FOLDER_UNIT, "qualitycontrol", "test_qc.json")


def check_data(id):
    switcher = {
        "passed_formula": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed formula check",
            "precondition": {},
            "evaluator": {
                "parameters": [
                    {"name": "K", "value": 13368936},
                ],  # computest 2.03 * valid max of oa01_radiance + valid_max of oa02_radiance
                "variables": [
                    {"name": "var1", "path": "oa01_radiance"},
                    {"name": "var2", "path": "oa02_radiance"},
                ],
                "attributes": [{"name": "coeff", "path": "other_metadata/radiance_coeff"}],
                "formula": "(var1.max() * coeff + var2.max() ) < K",
            },
        },
        "failed_formula": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed formula check",
            "precondition": {},
            "evaluator": {
                "parameters": [{"name": "K", "value": 0}],
                "variables": [
                    {"name": "var1", "path": "oa01_radiance"},
                    {"name": "var2", "path": "oa02_radiance"},
                ],
                "attributes": [{"name": "coeff", "path": "other_metadata/radiance_coeff"}],
                "formula": "(var1.max() * coeff + var2.max() ) < K",
            },
        },
        "passed_formula_precond_ok": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "valid formula check",
            "precondition": {
                "parameters": [
                    {"name": "ACCTYPE", "value": "INS-NOBS"},
                ],  # computest 2.03 * valid max of oa01_radiance + valid_max of oa02_radiance
                "variables": [],
                "attributes": [{"name": "DTYPE", "path": "other_metadata/datatake_type"}],
                "formula": "DTYPE == ACCTYPE",
            },
            "evaluator": {
                "parameters": [
                    {"name": "K", "value": 13368936},
                ],  # computest 2.03 * valid max of oa01_radiance + valid_max of oa02_radiance
                "variables": [
                    {"name": "var1", "path": "oa01_radiance"},
                    {"name": "var2", "path": "oa02_radiance"},
                ],
                "attributes": [{"name": "coeff", "path": "other_metadata/radiance_coeff"}],
                "formula": "(var1.max() * coeff + var2.max() ) < K",
            },
        },
        "passed_formula_precond_nok": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "valid formula check",
            "precondition": {
                "parameters": [
                    {"name": "ACCTYPE", "value": "INS-DASC"},
                ],  # computest 2.03 * valid max of oa01_radiance + valid_max of oa02_radiance
                "variables": [],
                "attributes": [{"name": "DTYPE", "path": "other_metadata/datatake_type"}],
                "formula": "DTYPE == ACCTYPE",
            },
            "evaluator": {
                "parameters": [
                    {"name": "K", "value": 13368936},
                ],  # computest 2.03 * valid max of oa01_radiance + valid_max of oa02_radiance
                "variables": [
                    {"name": "var1", "path": "oa01_radiance"},
                    {"name": "var2", "path": "oa02_radiance"},
                ],
                "attributes": [{"name": "coeff", "path": "other_metadata/radiance_coeff"}],
                "formula": "(var1.max() * coeff + var2.max() ) < K",
            },
        },
        "security_issue_formula": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "security issue check",
            "precondition": {},
            "evaluator": {
                "parameters": [{"name": "K", "value": 0}],
                "variables": [
                    {"name": "var1", "path": "oa01_radiance"},
                    {"name": "var2", "path": "oa02_radiance"},
                ],
                "attributes": [{"name": "coeff", "path": "other_metadata/radiance_coeff"}],
                "formula": "__import__(os)",
            },
        },
        "passed_valid_range": {
            "identifier": "valid_range",
            "version": "0.0.1",
            "thematic": "RADIOMETRIC_QUALITY",
            "description": "passed_valid_range check",
            "precondition": {},
            "variables": ["oa01_radiance"],
            "min": 0,
            "max": 65534,
            "strict": False,
        },
        "failed_valid_range": {
            "identifier": "valid_range",
            "version": "0.0.1",
            "thematic": "RADIOMETRIC_QUALITY",
            "description": "failed_valid_range check",
            "precondition": {},
            "variables": ["oa01_radiance"],
            "min": 0,
            "max": 1,
            "strict": False,
        },
        "passed_path_exists": {
            "identifier": "path_exists",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed var exist",
            "precondition": {},
            "variables": ["measurements/radiance/oa01_radiance"],
        },
        "failed_path_exists": {
            "identifier": "path_exists",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed var exists",
            "precondition": {},
            "variables": ["measurements/radiance/oa11_radiance"],
        },
        "passed_var_counts": {
            "identifier": "var_counts",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed var counts",
            "precondition": {},
            "variables": ["measurements/radiance"],
            "expected": 2,
        },
        "failed_var_counts": {
            "identifier": "var_counts",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed var counts",
            "precondition": {},
            "variables": ["measurements/radiance"],
            "expected": 1,
        },
        "passed_var_notzerosized": {
            "identifier": "var_counts",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed var zerosized",
            "precondition": {},
            "variables": ["measurements/radiance/oa01_radiance"],
        },
        "failed_var_notzerosized": {
            "identifier": "var_counts",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed var zerosized",
            "precondition": {},
            "variables": ["measurements/empty"],
        },
        "eoqc_runner": {
            "identifier": "check_3",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "eoqc_runner check",
            "precondition": {},
            "module": "tests.ut.qualitycontrol",
            "eoqc_class": "QC01",
            "parameters": {
                "threshold": 23,
                "param_2": 65,
                "adf_probas": {"path": "path_to_the_needed_aux_data", "name": "proba"},
            },
        },
        "validate": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "valid product check",
            "precondition": {},
        },
        "history": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "valid product check",
            "precondition": {},
        },
        "passed_product_data_size": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "Evaluate the data size in Bytes for anomaly detection",
            "precondition": {},
            "min": 1048576,
            "max": 10737418240,
        },
        "failed_product_data_size": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "Evaluate the data size in Bytes for anomaly detection",
            "precondition": {},
            "min": 10737418240,
            "max": 10737418240,
        },
        "passed_product_attr_size": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "Evaluate the attr size in Bytes for anomaly detection",
            "precondition": {},
            "min": 1,
            "max": 1048576,
        },
        "failed_product_attr_size": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "Evaluate the attr size in Bytes for anomaly detection",
            "precondition": {},
            "min": 1048576,
            "max": 1048576,
        },
        "malformed": {
            "identifier": "check_1",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "precondition": {},
        },
        "passed_attr_in_list": {
            "identifier": "attr_in_list",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed attr in list check",
            "precondition": {},
            "attributes": ["other_metadata/datatake_type"],
            "possible_values": ["INS-NOBS"],
        },
        "failed_attr_in_list": {
            "identifier": "attr_in_list",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed attr in list check",
            "precondition": {},
            "attributes": ["other_metadata/datatake_type"],
            "possible_values": ["INS-DASC"],
        },
        "passed_attr_match": {
            "identifier": "attr_matches",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed attr match regex",
            "precondition": {},
            "attributes": ["other_metadata/datatake_type"],
            "pattern": "INS-[A-Z]{4}",
        },
        "failed_attr_match": {
            "identifier": "attr_matches",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed attr match",
            "precondition": {},
            "attributes": ["other_metadata/datatake_type"],
            "pattern": "[a-z]*",
        },
        "passed_attr_exists": {
            "identifier": "attr_exists",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed attr exist",
            "precondition": {},
            "attributes": ["other_metadata/datatake_type"],
        },
        "failed_attr_exists": {
            "identifier": "attr_exists",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed attr exists",
            "precondition": {},
            "attributes": ["other_metadata/datatake_typop"],
        },
        "passed_attr_count": {
            "identifier": "attr_count",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed attr count",
            "precondition": {},
            "attributes": ["other_metadata/integration_time"],
            "expected": 13,
        },
        "failed_attr_count": {
            "identifier": "attr_count",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "failed attr count",
            "precondition": {},
            "attributes": ["other_metadata/integration_time"],
            "expected": 1,
        },
        "passed_attr_in_range": {
            "identifier": "attr_count",
            "version": "0.0.1",
            "thematic": "RADIOMETRIC_QUALITY",
            "description": "passed attr in range",
            "precondition": {},
            "attributes": ["other_metadata/integration_time/b01", "other_metadata/integration_time/b02"],
            "min": 0.1,
            "max": 1.5,
            "strict": True,
        },
        "failed_attr_in_range": {
            "identifier": "attr_count",
            "version": "0.0.1",
            "thematic": "RADIOMETRIC_QUALITY",
            "description": "failed attr count",
            "precondition": {},
            "attributes": ["other_metadata/integration_time/b01", "other_metadata/integration_time/b02"],
            "min": 10,
            "max": 15,
            "strict": False,
        },
        "dimensions": {
            "identifier": "dimension_check",
            "version": "0.0.1",
            "thematic": "GENERAL_QUALITY",
            "description": "passed dimensions",
            "precondition": {},
        },
    }
    return switcher.get(id, None)
