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

from eopf import EOConfiguration
from eopf.common.file_utils import AnyPath
from eopf.computing.breakpoint import (
    declare_as_breakpoint,
    eopf_breakpoint_decorator,
    get_breakpoints_config,
)
from eopf.product.conveniences import init_datatree


def real_func(*args, **kwargs):
    return {"out": init_datatree("test")}


class RealClass:
    def __call__(self, *args, **kwargs):
        print("calledd ")
        return self.run(*args, **kwargs)

    def run(*args, **kwargs):
        return {"out": init_datatree("")}


@pytest.fixture
def breakpoints_dir(OUTPUT_DIR):
    return os.path.join(OUTPUT_DIR, "breakpoints")


@pytest.fixture
def breakpoints_dir_s3(s3_output_test_data):
    protocol, base_path = s3_output_test_data
    return f"{protocol}://{base_path}/breakpoints"


@pytest.fixture
def setup_breakpoint_configuration_all(breakpoints_dir):
    EOConfiguration()["breakpoints__activate_all"] = True
    EOConfiguration()["breakpoints__folder"] = breakpoints_dir

    yield

    EOConfiguration()["breakpoints__activate_all"] = False


@pytest.fixture
def setup_breakpoint_configuration(breakpoints_dir):
    eopf_breakpoint_decorator(identifier="test")(real_func)
    EOConfiguration()["breakpoints__test"] = True
    EOConfiguration()["breakpoints__folder"] = breakpoints_dir

    yield

    EOConfiguration()["breakpoints__test"] = False


@pytest.mark.unit
@pytest.mark.dask_only
def test_breakpoint_on_func_all(setup_breakpoint_configuration_all, breakpoints_dir):
    print(breakpoints_dir)
    wrapper = eopf_breakpoint_decorator(identifier="test")(real_func)
    wrapper()
    brk_result = AnyPath.cast(breakpoints_dir).ls()
    assert len(brk_result) != 0
    for f in brk_result:
        f.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.real_s3
@pytest.mark.dask_only
def test_breakpoint_on_func_all_s3(setup_breakpoint_configuration_all, breakpoints_dir_s3, s3_output_config_real):
    print(breakpoints_dir_s3)
    EOConfiguration()["breakpoints__folder"] = breakpoints_dir_s3
    EOConfiguration()["breakpoints__storage_options"] = s3_output_config_real
    wrapper = eopf_breakpoint_decorator(identifier="test")(real_func)
    wrapper()
    brk_result = AnyPath.cast(breakpoints_dir_s3, **s3_output_config_real).ls()
    assert len(brk_result) > 0
    for f in brk_result:
        f.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.dask_only
def test_breakpoint_on_func(setup_breakpoint_configuration, breakpoints_dir):
    print(breakpoints_dir)
    wrapper = eopf_breakpoint_decorator(identifier="testko")(real_func)
    wrapper()
    brk_result = AnyPath.cast(breakpoints_dir).ls()
    assert len(brk_result) == 0
    wrapper = eopf_breakpoint_decorator(identifier="test")(real_func)
    wrapper()
    brk_result = AnyPath.cast(breakpoints_dir).ls()
    assert len(brk_result) != 0
    for f in brk_result:
        f.rm(recursive=True)


@pytest.mark.unit
@pytest.mark.dask_only
def test_breakpoint_on_data(setup_breakpoint_configuration, breakpoints_dir):
    data = init_datatree("testdata")
    brkp_tri = declare_as_breakpoint(data, "testko")
    brkp_tri()
    brk_result = AnyPath.cast(breakpoints_dir).ls()
    assert len(brk_result) == 0
    brkp_tri = declare_as_breakpoint(data, "test")
    brkp_tri()
    brk_result = AnyPath.cast(breakpoints_dir).ls()
    assert len(brk_result) != 0


@pytest.mark.unit
def test_breakpoint_get_configuration(setup_breakpoint_configuration, breakpoints_dir):
    conf = get_breakpoints_config()
    assert len(conf) > 0
    assert len(conf["ids"]) > 0
