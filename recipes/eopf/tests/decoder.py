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
import json

from netCDF4 import Dataset


class Netcdfdecoder:
    def __init__(self, url_or_obj: str, mode: str = "r"):
        if isinstance(url_or_obj, str):
            self._node = Dataset(url_or_obj, mode=mode)
        else:
            self._node = url_or_obj

    def __getitem__(self, key: str):
        return Netcdfdecoder(self._node[key])

    @property
    def attrs(self):
        result = dict()
        for key, value in self._node.__dict__.items():
            try:
                result[key] = json.loads(value)
            except json.decoder.JSONDecodeError:
                result[key] = value
        return result
