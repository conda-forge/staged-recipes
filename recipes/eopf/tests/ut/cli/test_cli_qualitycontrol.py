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

from eopf import write_datatree
from eopf.cli.cli_qualitycontrol import qualitycontrol_check
from eopf.common.file_utils import AnyPath


@pytest.mark.unit
def test_cli_qualitycontrol(fake_template_product, OUTPUT_DIR):
    output_dir = os.path.join(OUTPUT_DIR, "cli_eoqc")
    AnyPath.cast(output_dir).mkdir(exist_ok=True)

    input_file = os.path.join(output_dir, fake_template_product.cpm.product_id() + ".zarr")
    write_datatree(fake_template_product, input_file, engine="cpm_zarr")

    runner = CliRunner()
    output_report = os.path.join(output_dir, "reports")
    AnyPath.cast(output_report).mkdir(exist_ok=True)

    r = runner.invoke(
        qualitycontrol_check,
        args=[input_file, "--report-folder", output_report],
    )

    if r.exception is not None:
        traceback.print_exception(type(r.exception), r.exception, r.exception.__traceback__)

    assert r.exception is None
    assert r.exit_code == 0
    assert AnyPath.cast(output_report).exists()

    AnyPath.cast(output_dir).rm(recursive=True)


@pytest.mark.unit
def test_cli_qualitycontrol_requires_output(fake_template_product, OUTPUT_DIR):
    output_dir = os.path.join(OUTPUT_DIR, "cli_eoqc")
    AnyPath.cast(output_dir).mkdir(exist_ok=True)

    input_file = os.path.join(output_dir, fake_template_product.cpm.product_id() + ".zarr")
    write_datatree(fake_template_product, input_file, engine="cpm_zarr")

    runner = CliRunner()
    r = runner.invoke(qualitycontrol_check, args=[input_file])

    assert r.exit_code != 0
    assert "Need at least one" in r.output
