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
import re

import pytest

from eopf.exceptions.errors import EOQCError
from eopf.qualitycontrol.eo_qc import EOQC
from eopf.qualitycontrol.eo_qc_factory import EOQCFactory
from tests.ut.qualitycontrol import check_data


@pytest.mark.unit
@pytest.mark.parametrize(
    "name, qc_dict",
    [
        ("formulas", check_data("passed_formula")),
        ("var_in_range", check_data("passed_valid_range")),
        ("path_exists", check_data("passed_path_exists")),
        ("var_count", check_data("passed_var_counts")),
        ("var_notzerosize", check_data("passed_var_notzerosized")),
        ("eoqc_runner", check_data("eoqc_runner")),
        ("attr_in_list", check_data("passed_attr_in_list")),
        ("attr_matches", check_data("passed_attr_match")),
        ("attr_exists", check_data("passed_attr_exists")),
        ("attr_count", check_data("passed_attr_count")),
        ("attr_in_range", check_data("passed_attr_in_range")),
        ("product_data_size", check_data("passed_product_data_size")),
        ("product_attr_size", check_data("passed_product_attr_size")),
        ("dimensions", check_data("dimensions")),
        ("validate", check_data("validate")),
        ("product_processing_history", check_data("history")),
    ],
)
def test_eoqc_impl_init(name, qc_dict):
    eoqc_type = EOQCFactory.get_eoqc_type(name)
    assert issubclass(eoqc_type, EOQC)
    eoqc = EOQCFactory.get_eoqc_instance(eoqc_name=name, data=qc_dict)
    assert eoqc is not None


@pytest.mark.unit
@pytest.mark.parametrize(
    "name, qc_dict, result, message",
    [
        (
               "formulas",
            check_data("passed_formula"),
            True,
               r"PASSED: Formula \(var1\.max\(\) \* coeff \+ var2\.max\(\) \) < K evaluate "
            "True on the product test",
        ),
        (
            "formulas",
            check_data("passed_formula_precond_ok"),
            True,
            r"PASSED: Formula \(var1\.max\(\) \* coeff \+ var2\.max\(\) \) < K evaluate "
            "True on the product test",
        ),
        (
            "formulas",
            check_data("passed_formula_precond_nok"),
            True,
            "SKIPPED: Precondition evaluate False with formula : DTYPE == ACCTYPE",
        ),
        (
            "var_in_range",
            check_data("passed_valid_range"),
            True,
            "PASSED: Variable oa01_radiance is within 0.0 and 65534.0",
        ),
        (
            "var_in_range",
            check_data("failed_valid_range"),
            False,
            "FAILED: Variable oa01_radiance is not within 0.0 and 1.0",
        ),
        (
            "path_exists",
            check_data("passed_path_exists"),
            True,
            "PASSED : Variable/Group measurements/radiance/oa01_radiance is available in product",
        ),
        (
            "path_exists",
            check_data("failed_path_exists"),
            False,
            "FAILED : Variable/Group measurements/radiance/oa11_radiance is not available in product for check "
            "EOQCPathAvailable",
        ),
        (
            "var_count",
            check_data("passed_var_counts"),
            True,
            "PASSED: 2 elements found under measurements/radiance",
        ),
        (
            "var_count",
            check_data("failed_var_counts"),
            False,
            "FAILED: Expected 1 elements under 'measurements/radiance', found 2",
        ),
        (
            "var_notzerosize",
            check_data("passed_var_notzerosized"),
            True,
            "PASSED: measurements/radiance/oa01_radiance variable has data",
        ),
        ("eoqc_runner", check_data("eoqc_runner"), True, "OK"),
        (
            "formulas",
            check_data("failed_formula"),
            False,
            r"FAILED: Formula \(var1\.max\(\) \* coeff \+ var2\.max\(\) \) < K "
            "evaluate False on the product test",
        ),
        (
            "validate",
            check_data("validate"),
            True,
            "PASSED: The product test has valid structure;STAC datetime are valid",
        ),
        (
            "product_processing_history",
            check_data("history"),
            True,
            "PASSED : Processing history is valid for DataTree: test",
        ),
        (
            "dimensions",
            check_data("dimensions"),
            False,
            "FAILED : Dimension 'dim_0' has inconsistent lengths: 10 at measurements/empty_group/empty, but 1000 at measurements/radiance/oa01_radiance. If resolutions differ, use dimension names x_10m, x_20m, etc.;Dimension 'dim_0' has inconsistent coordinate values between measurements/empty_group/empty and measurements/radiance/oa01_radiance. If grids differ, use different dimension names.;Dimension 'dim_1' has inconsistent lengths: 10 at measurements/empty_group/empty, but 1000 at measurements/radiance/oa01_radiance. If resolutions differ, use dimension names x_10m, x_20m, etc.;Dimension 'dim_1' has inconsistent coordinate values between measurements/empty_group/empty and measurements/radiance/oa01_radiance. If grids differ, use different dimension names.",
        ),
        (
            "product_data_size",
            check_data("passed_product_data_size"),
            True,
            r"PASSED: The product test datasize \(\d+\) is within range \[1048576,10737418240\]",
        ),
        (
            "product_data_size",
            check_data("failed_product_data_size"),
            False,
            r"FAILED: The product test datasize \(\d+\) is not within range \[10737418240,10737418240\]",
        ),
        (
            "product_attr_size",
            check_data("passed_product_attr_size"),
            True,
            r"PASSED: The product test attr size \(\d+\) is within range \[1,1048576\]",
        ),
        (
            "product_attr_size",
            check_data("failed_product_attr_size"),
            False,
            r"FAILED: The product test attr size \(\d+\) is not within range \[1048576,1048576\]",
        ),
        (
            "attr_in_list",
            check_data("passed_attr_in_list"),
            True,
            "PASSED: other_metadata/datatake_type:INS-NOBS is in the possible list \['INS-NOBS'\]",
        ),
        (
            "attr_in_list",
            check_data("failed_attr_in_list"),
            False,
            "FAILED: other_metadata/datatake_type:INS-NOBS is not in the possible list \['INS-DASC'\]",
        ),
        (
            "attr_matches",
            check_data("passed_attr_match"),
            True,
            "PASSED: other_metadata/datatake_type value INS-NOBS is matching the pattern INS-\[A-Z\]\{4\}",
        ),
        (
            "attr_matches",
            check_data("failed_attr_match"),
            False,
            "FAILED: other_metadata/datatake_type value INS-NOBS is not matching the pattern \[a-z\]\*",
        ),
        (
            "attr_exists",
            check_data("passed_attr_exists"),
            True,
            "PASSED : Attribute other_metadata/datatake_type is available in product",
        ),
        (
            "attr_exists",
            check_data("failed_attr_exists"),
            False,
            "FAILED : Attribute other_metadata/datatake_typop is not available in product for check "
            "EOQCAttrAvailable",
        ),
        (
            "attr_count",
            check_data("passed_attr_count"),
            True,
            "PASSED: 13 attributes found under other_metadata/integration_time",
        ),
        (
            "attr_count",
            check_data("failed_attr_count"),
            False,
            "FAILED: Expected 1 attributes under other_metadata/integration_time, found 13",
        ),
        (
            "attr_in_range",
            check_data("passed_attr_in_range"),
            True,
            "PASSED: other_metadata/integration_time/b01 is strictly within 0.1 and 1.5 ; PASSED: "
            "other_metadata/integration_time/b02 is strictly within 0.1 and 1.5",
        ),
        (
            "attr_in_range",
            check_data("failed_attr_in_range"),
            False,
            "FAILED: other_metadata/integration_time/b01 is not within 10.0 and 15.0 ; FAILED: "
            "other_metadata/integration_time/b02 is not within 10.0 and 15.0",
        ),
    ],
)
def test_eoqc_impl_check(fake_quality_datatree, name, qc_dict, result, message):
    eoqc_type = EOQCFactory.get_eoqc_type(name)
    assert issubclass(eoqc_type, EOQC)
    eoqc = EOQCFactory.get_eoqc_instance(name, qc_dict)
    assert eoqc is not None
    print(fake_quality_datatree.attrs)
    res = eoqc.check(fake_quality_datatree)
    print(res)
    assert res.status == result
    assert res.identifier == eoqc.identifier
    assert res.version == eoqc.version
    assert res.description == eoqc.description
    assert re.fullmatch(message, res.message)


@pytest.mark.unit
def test_security_issue(fake_quality_datatree):
    eoqc = EOQCFactory.get_eoqc_instance("formulas", check_data("security_issue_formula"))
    print(eoqc)
    assert eoqc is not None
    with pytest.raises(ValueError):
        eoqc.check(fake_quality_datatree)


@pytest.mark.unit
def test_malformed():
    data = check_data("malformed")
    with pytest.raises(EOQCError):
        EOQCFactory.get_eoqc_instance("validate", data)
