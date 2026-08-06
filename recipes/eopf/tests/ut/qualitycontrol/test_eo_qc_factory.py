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

from eopf.qualitycontrol.eo_qc import EOQC
from eopf.qualitycontrol.eo_qc_factory import EOQCFactory


@pytest.mark.unit
def test_eoqc_factory_list_available():
    assert len(EOQCFactory.get_eoqc_available()) != 0


@pytest.mark.unit
def test_eoqc_factory_get_eoqcs():
    for eoqc in EOQCFactory.get_eoqc_available():
        eoqc_type = EOQCFactory.get_eoqc_type(eoqc)
        assert issubclass(eoqc_type, EOQC)


@pytest.mark.unit
def test_eoqc_factory_get_wrong_eoqc():
    with pytest.raises(KeyError):
        EOQCFactory.get_eoqc_type("trucbidule")
