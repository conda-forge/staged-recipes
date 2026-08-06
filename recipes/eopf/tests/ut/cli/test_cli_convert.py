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
import traceback

import pytest
from click.testing import CliRunner

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")
pytest.importorskip("distributed")

from eopf.cli.cli_convert import convert_cli
from eopf.common.file_utils import AnyPath


@pytest.fixture
def input_path(request) -> str:
    return request.getfixturevalue(request.param)


@pytest.mark.unit
@pytest.mark.parametrize(
    "input_path, glob_pattern",
    [
        pytest.param("S3_OL_1_unit", "S03OLCERR*", marks=pytest.mark.need_files),
    ],
    indirect=["input_path"],
)
def test_cli_convert(input_path, glob_pattern, OUTPUT_DIR):
    runner = CliRunner()
    output_sub_dir = os.path.join(OUTPUT_DIR, "cli_convert")
    AnyPath.cast(output_sub_dir).mkdir(exist_ok=True)
    r = runner.invoke(
        convert_cli,
        args=" ".join(
            [input_path, OUTPUT_DIR, "--target-engine", "cpm_zarr", "--naming-strategy", "PRODUCT_ID"],
        ),
    )
    if r.exception is not None:
        traceback.print_exception(type(r.exception), r.exception, r.exception.__traceback__)
    assert r.exception is None
    assert r.exit_code == 0
    assert AnyPath.cast(output_sub_dir).glob(glob_pattern) != 0
    AnyPath.cast(output_sub_dir).rm(recursive=True)
