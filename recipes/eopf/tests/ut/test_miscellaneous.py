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
import hypothesis.extra.numpy as xps
import hypothesis.strategies as st
import pytest

pytestmark = pytest.mark.dask_only
pytest.importorskip("distributed")

from distributed.utils_test import loop_in_thread  # noqa



@st.composite
def value_with_type(draw, elements=st.integers(), expected_type=int, expected_container_type=None):
    if isinstance(expected_type, st.SearchStrategy):
        expected_type = draw(expected_type)

    if expected_container_type is not None:
        if isinstance(expected_container_type, st.SearchStrategy):
            expected_container_type = draw(expected_container_type)
        return (draw(elements), expected_type, expected_container_type)

    return (draw(elements), expected_type)


@st.composite
def numpy_value(draw, dtype_st=xps.scalar_dtypes(), allow_infinity=True, allow_nan=True):
    return draw(xps.from_dtype(draw(dtype_st), allow_infinity=allow_infinity, allow_nan=allow_nan))
