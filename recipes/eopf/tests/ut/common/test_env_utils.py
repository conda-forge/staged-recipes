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
from pathlib import Path

import pytest

from eopf.common import env_utils
from eopf.common.env_utils import resolve_env_vars


@pytest.mark.unit
def test_env_context():
    with env_utils.env_context({"TRUC": "MACHIN"}) as e:
        assert "TRUC" in e.keys()


@pytest.mark.unit
def test_env_context_eopf():
    with env_utils.env_context_eopf() as e:
        assert "EOPF_ROOT" in e.keys()


@pytest.mark.unit
def test_expand_env_var_in_dict():
    in_dict = {"truc": {"bidule": 3}, "machin": "$TEST"}
    res_dict = {"truc": {"bidule": 3}, "machin": "2"}
    os.environ.setdefault("TEST", "2")
    out_dict = resolve_env_vars(in_dict)
    assert out_dict == res_dict


@pytest.mark.unit
def test_resolve_env_vars_raises_on_unresolved_variables(monkeypatch):
    monkeypatch.delenv("UNDEFINED_ENV_VAR", raising=False)

    with pytest.raises(ValueError, match="UNDEFINED_ENV_VAR"):
        resolve_env_vars("$UNDEFINED_ENV_VAR/file.txt")

    with pytest.raises(ValueError, match="UNDEFINED_ENV_VAR"):
        resolve_env_vars(Path("$UNDEFINED_ENV_VAR/file.txt"))
