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
from click.testing import CliRunner

from eopf import __version__
from eopf.cli.cli import eopf_cli


@pytest.mark.unit
@pytest.mark.parametrize("opts", [("--help",)])
def test_cli(opts):
    runner = CliRunner()
    r = runner.invoke(eopf_cli, args=opts)
    assert r.exit_code == 0
    print(r.output)
    # fmt: off
    assert r.output == f"""Usage: eopf [OPTIONS] COMMAND [ARGS]...

  CPM Command line tools

  CPM Version {__version__}

Options:
  --version  Show the version and exit.
  --help     Show this message and exit.

Commands:
  convert         Convert a product to another format.
  kafka-consumer  Consume Kafka messages and execute EOTrigger.
  merge           Merge multiple S2 L1C or S2 L2A products into a single one.
  model           CLI commands for pydantic model handling
  qualitycontrol  CLI commands to run EOQC processor
  trigger         CLI commands to trigger EOProcessingUnit
  validate        Validate a product.
  web-server      Run web services to execute EOTrigger from POST payloads.
"""
