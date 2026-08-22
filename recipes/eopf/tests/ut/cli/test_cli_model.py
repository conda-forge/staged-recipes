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

from eopf.cli.cli_model import create_model, validate_model
from eopf.common.file_utils import AnyPath

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")


@pytest.mark.need_files
@pytest.mark.unit
def test_cli_model(OUTPUT_DIR, S2_MSIL2A_unit):
    runner = CliRunner()
    output_model_file = os.path.join(OUTPUT_DIR, "S2_MSIL2A.json")

    r = runner.invoke(
        create_model,
        args=[S2_MSIL2A_unit, "--target-path", output_model_file],
    )
    if r.exception is not None:
        traceback.print_exception(type(r.exception), r.exception, r.exception.__traceback__)
    assert r.exception is None
    assert r.exit_code == 0
    assert AnyPath.cast(output_model_file).exists()

    r = runner.invoke(
        validate_model,
        args=[S2_MSIL2A_unit, "--model-path", output_model_file],
    )
    if r.exception is not None:
        traceback.print_exception(type(r.exception), r.exception, r.exception.__traceback__)
    assert r.exception is None
    assert r.exit_code == 0
    assert AnyPath.cast(output_model_file).exists()
