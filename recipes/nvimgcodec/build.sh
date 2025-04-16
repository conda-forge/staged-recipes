#! bash
# Copyright (c) 2024, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
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

set -ex

export CUDAARCHS="50"

mkdir build
cd build

nvimg_build_args=(
    -DBUILD_DOCS:BOOL=OFF
    -DBUILD_SAMPLES:BOOL=OFF
    -DBUILD_TEST:BOOL=OFF
    -DCUDA_TARGET_ARCHS=${CUDAARCHS}
# Library args
    -DBUILD_LIBRARY:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_STATIC_LIBS:BOOL=OFF
# "DYNAMIC_LINK" means using dlopen, but we want to link to shared libraries?
    -DWITH_DYNAMIC_LINK:BOOL=OFF
# Extension args
    -DBUILD_EXTENSIONS:BOOL=OFF
# Python args
    -DBUILD_PYTHON:BOOL=ON
    -DPYTHON_VERSIONS="${PY_VER}"
    -DBUILD_WHEEL:BOOL=OFF
    -DNVIMGCODEC_COPY_LIBS_TO_PYTHON_DIR:BOOL=OFF
    -DNVIMGCODEC_BUILD_PYBIND11:BOOL=OFF
    -DNVIMGCODEC_BUILD_DLPACK:BOOL=OFF
)

cmake ${CMAKE_ARGS} -GNinja "${nvimg_build_args[@]}" ${SRC_DIR}

cmake --build .

cmake --install . --strip

$PYTHON -m pip install --no-deps --no-build-isolation -v $SRC_DIR/build/python

