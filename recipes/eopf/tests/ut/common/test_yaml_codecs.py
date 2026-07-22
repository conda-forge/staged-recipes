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
"""Tests for YAML codec conversion helpers."""

from unittest import mock

import pytest

from eopf.common.yaml_codecs import BloscSpec, build_blosc_codec


@pytest.mark.unit
def test_build_blosc_codec_forwards_blocksize():
    with mock.patch("eopf.common.yaml_codecs.get_blosc_codec", return_value=object()) as get_blosc_codec:
        build_blosc_codec(
            BloscSpec(cname="zstd", clevel=3, shuffle=2, blocksize=128),
            zarr_format=3,
        )

    get_blosc_codec.assert_called_once_with(
        zarr_format=3,
        cname="zstd",
        clevel=3,
        shuffle=2,
        blocksize=128,
    )
