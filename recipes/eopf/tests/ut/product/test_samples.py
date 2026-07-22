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

"""
SAMPLE
 - group
    - variable_with_flags
    - subgroup
       - variable
"""
from xarray import DataArray, DataTree

product_attrs = {"product:type": "ptype"}

group_attrs = {
    "dimensions": (),
    "documentation": "This is the group documentation",
    "description": "Sample group",
}

subgroup_attrs = {
    "dimensions": (),
    "documentation": "This is the subgroup documentation",
    "description": "Sample subgroup",
}

variable_with_flags_attrs = {
    "_ARRAY_DIMENSIONS": (),
    "dimensions": (),
    "documentation": "This is a variable with associated flags",
    "description": "Flag Variable",
    "flag_values": [1, 2, 4],
    "flag_meanings": "coastline ocean tidal",
}

variable_attrs = {
    "_ARRAY_DIMENSIONS": (),
    "dimensions": (),
    "documentation": "This is the variable documentation",
    "description": "Sample Variable",
    "complex_attribute": {"p1": 1, "p2": {"type": "list", "data": [1, 2, 3]}},
}

param1_attrs = {"long_name": "Parameter 1", "value": 1}
param2_attrs = {"long_name": "Parameter 2", "value": 2}

TEST_EOPRODUCT = DataTree(name="SAMPLE")
TEST_EOPRODUCT.attrs=product_attrs

TEST_EOPRODUCT["group"] = DataTree()
TEST_EOPRODUCT["group"].attrs=group_attrs
group = TEST_EOPRODUCT["group"]

group["subgroup"] = DataTree()
group["subgroup"].attrs=subgroup_attrs

group["variable_with_flags"] = DataArray()
group["variable_with_flags"].attrs.update(variable_with_flags_attrs)

subgroup = group["subgroup"]

subgroup["variable"] = DataArray()
subgroup["variable"].attrs.update(variable_attrs)

TEST_DATATREE = TEST_EOPRODUCT
