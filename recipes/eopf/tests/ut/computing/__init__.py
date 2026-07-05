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


class CountingScheduler:
    """Simple dask scheduler counting the number of computes.

    Reference: https://stackoverflow.com/questions/53289286/"""

    def __init__(self, max_computes=0):
        self.total_computes = 0
        self.max_computes = max_computes

    def __call__(self, dsk, keys, **kwargs):
        dask = pytest.importorskip("dask")
        self.total_computes += 1
        if self.total_computes > self.max_computes:
            raise RuntimeError("Too many computes. Total: %d > max: %d." % (self.total_computes, self.max_computes))
        return dask.get(dsk, keys, **kwargs)


def raise_if_dask_computes(max_computes=0):
    dask = pytest.importorskip("dask")
    scheduler = CountingScheduler(max_computes)
    return dask.config.set(scheduler=scheduler)
