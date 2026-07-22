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

import numpy as np
import pytest
from xarray import DataArray, Dataset, DataTree

from eopf.store.l0_writers import L0Writers


@pytest.fixture
def s3_l0_datatree():
    """
    Build a real DataTree that imitates the S3-L0 product structure.
    No mocking. Fully navigable datatree with correct subpaths.
    """

    # -------------------------------
    # Root node with metadata
    # -------------------------------
    root = DataTree(
        name="",
    )
    root.attrs = {
        "granule": [1],
        "stac_discovery": {
            "properties": {
                "providers": [{"name": "CS"}, {"name": "CS"}],
                "sat:platform_international_designator": "S2B",
                "platform": "S2B",
                "created": "20241021",
                "eopf:data_take_id": 255,
                "processing:software": {"IPF-0": "6.14"},
            },
            "geometry": {"coordinates": "1 1 1 1"},
            "id": "product_id",
        },
        "other_metadata": {
            "hh_receive_channel_id": 1,
            "hv_receive_channel_id": 1,
            "vv_receive_channel_id": 1,
            "packet_version": 1,
            "packet_type": 1,
            "header_flag": 1,
            "application_process_identifer": 1,
            "packet_category": 1,
            "sequence_flag": 1,
            "synchronisation_marker": 1,
            "event_control_code": 1,
            "test_mode": 1,
            "vh_receive_channel_id": 1,
            "instrument_configuration_id": 1,
            "PRODUCT": {"properties": {"providers": [{"name": "CS"}, {"name": "CS"}]}},
            "product_unit": {"type": "L1C"},
            "absolute_pass_number": 128,
            "ephemeris": {
                "start": {
                    "UTC": "2021-08-08T01:01:01.888Z",
                    "position": {"x": 1, "y": 1},
                    "velocity": {"x": 1, "y": 1},
                },
                "stop": {
                    "UTC": "2021-08-08T01:01:01.888Z",
                    "position": {"x": 1, "y": 1},
                    "velocity": {"x": 1, "y": 1},
                },
            },
        },
    }

    # -------------------------------
    # CONDITIONS GROUP
    # -------------------------------
    packet_data_length = DataArray(
        np.full(1, fill_value=30, dtype=np.uint32),
        dims=("dim",),
    )
    root["conditions/packet_data_length"] = packet_data_length

    # -------------------------------
    # MEASUREMENTS / ISP
    # -------------------------------
    data = np.full((39477, 58), fill_value=1, dtype=np.uint8)
    isp = DataArray(
        data=data,
        dims=("packet_number", "max_data_length"),
        attrs={
            "long_name": "instrument source packet",
            "short_name": "isp",
            "coordinates": (
                "gps_time_days",
                "gps_time_seconds",
                "gps_time_microseconds",
            ),
            "dimensions": ("packet_number", "max_data_length"),
        },
    )

    gps_time_days = np.random.randint(0, 5, size=39477, dtype=np.uint8)
    gps_time_seconds = np.random.randint(0, 5, size=39477, dtype=np.uint8)
    gps_time_microseconds = np.random.randint(0, 5, size=39477, dtype=np.uint8)

    isp = isp.assign_coords(
        {
            "gps_time_days": ("packet_number", gps_time_days),
            "gps_time_seconds": ("packet_number", gps_time_seconds),
            "gps_time_microseconds": ("packet_number", gps_time_microseconds),
        },
    )

    root["measurements/isp"] = isp

    return root


@pytest.mark.unit
def test_s3_l0_writers(OUTPUT_DIR, s3_l0_datatree):
    L0Writers.S3L0Writer(s3_l0_datatree, os.path.join(OUTPUT_DIR, "S3_L0.SAFE"))


def ensure_group(tree: DataTree, path: str) -> DataTree:
    """
    Ensure every node in the path exists and contains an empty Dataset().
    """
    parts = path.strip("/").split("/")
    cur = tree
    for p in parts:
        if p not in cur.children:
            cur[p] = DataTree(name=p, dataset=Dataset())
        cur = cur[p]
    return cur


@pytest.fixture
def s1_l0_tree_multi_pol():
    """
    Build a real, aligned DataTree suitable for S1/S3 L0 writer tests.
    """
    # ROOT
    root = DataTree(name="", dataset=Dataset())

    # Assign root attributes (must be done AFTER init)
    root.attrs = {
        "granule": [1],
        "stac_discovery": {
            "properties": {
                "providers": [{"name": "CS"}, {"name": "CS"}],
                "sat:platform_international_designator": "S2B",
                "processing:facility": "2BPS",
                "created": "20241021",
                "eopf:data_take_id": [255],
                "eopf:instrument_mode": "SM",
                "platform": "S2B",
            },
            "geometry": {"coordinates": "1 1 1 1"},
        },
        "other_metadata": {
            "hh_receive_channel_id": [1],
            "hv_receive_channel_id": [1],
            "vv_receive_channel_id": [1],
            "packet_version": [1],
            "packet_type": [1],
            "header_flag": [1],
            "application_process_identifer": [1],
            "packet_category": [1],
            "sequence_flag": [1],
            "synchronisation_marker": [1],
            "history": [{"processingTime": "2021-08-08T01:01:01.888Z"}],
            "event_control_code": [1],
            "test_mode": [1],
            "vh_receive_channel_id": [1],
            "instrument_configuration_id": [1],
            "product_unit": {"type": "L1C"},
            "orbit_reference": {
                "absolute_pass_number": 128,
                "ephemeris": {
                    "start": {
                        "UTC": "2021-08-08T01:01:01.888Z",
                        "position": {"x": 1, "y": 1},
                        "velocity": {"x": 1, "y": 1},
                    },
                    "stop": {
                        "UTC": "2021-08-08T01:01:01.888Z",
                        "position": {"x": 1, "y": 1},
                        "velocity": {"x": 1, "y": 1},
                    },
                },
            },
        },
    }

    # ------------------------------------------------------------------
    # CONDITIONS GROUP
    # ------------------------------------------------------------------

    for pol in ("hh", "hv", "vv", "vh"):
        root[f"conditions/{pol}/packet_data_length_{pol}"] = DataArray(np.full(1, 26, np.uint32))

    # root["conditions/fep"] = DataArray(np.full((1, 144 // 8), 1, np.uint8))

    for pol in ("hh", "hv", "vv", "vh"):
        root[f"conditions/{pol}/ssb_message"] = DataArray(np.full((1, 6), 1, np.uint8))

    # ------------------------------------------------------------------
    # MEASUREMENTS GROUP
    # ------------------------------------------------------------------
    ensure_group(root, "measurements")
    # root["measurements/user_data"] = DataArray(np.full((1, 12), 1, np.uint8))

    for pol in ("hh", "hv", "vv", "vh"):
        root[f"measurements/user_data_{pol}"] = DataArray(np.full((1, 10), 1, np.uint8))

    return root


@pytest.mark.unit
def test_s1_l0_writers(OUTPUT_DIR, s1_l0_tree_multi_pol):
    L0Writers.S1L0Writer(s1_l0_tree_multi_pol, os.path.join(OUTPUT_DIR, "S1_L0.SAFE"))
