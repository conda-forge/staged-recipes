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
import os.path
import time

import pytest

pytestmark = pytest.mark.dask_only
pytest.importorskip("dask")
pytest.importorskip("distributed")

from eopf.tracing import EOProgress


@pytest.mark.unit
def test_progress(OUTPUT_DIR):
    with EOProgress().cfg(report_path=os.path.join(OUTPUT_DIR, "progress_report.log")) as p:
        for i in range(10):
            time.sleep(0.1)
            p.step(step_progress=10)

    assert os.path.exists(os.path.join(OUTPUT_DIR, "progress_report.log"))
    os.remove(os.path.join(OUTPUT_DIR, "progress_report.log"))

    def a_func(p: EOProgress):
        time.sleep(0.5)
        p.step("first", step_progress=5)
        time.sleep(0.5)
        p.step("second", step_progress=10)
        time.sleep(0.5)
        p.step("third", step_progress=20)
        time.sleep(0.5)
        p.step("fourth", step_progress=40)
        time.sleep(0.5)
        p.step("fifth", step_progress=25)

    with EOProgress().cfg(report_path=os.path.join(OUTPUT_DIR, "progress_report_2.log")) as p:
        a_func(p)
    assert os.path.exists(os.path.join(OUTPUT_DIR, "progress_report_2.log"))
    os.remove(os.path.join(OUTPUT_DIR, "progress_report_2.log"))
