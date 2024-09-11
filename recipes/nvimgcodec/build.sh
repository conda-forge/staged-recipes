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

mkdir build
cd build

nvimg_build_args=(
    -DBUILD_DOCS:BOOL=OFF
    -DBUILD_SAMPLES:BOOL=OFF
    -DBUILD_TEST:BOOL=OFF
# Library args
    -DBUILD_LIBRARY:BOOL=OFF
    -DWITH_DYNAMIC_NVJPEG:BOOL=ON
    -DWITH_DYNAMIC_NVJPEG2K:BOOL=OFF
# Extension args
    -DBUILD_EXTENSIONS:BOOL=OFF
    -DBUILD_NVJPEG_EXT:BOOL=OFF
    # nvjpek2k is not yet on conda-forge
    -DBUILD_NVJPEG2K_EXT:BOOL=OFF
# Python args
    -DBUILD_PYTHON:BOOL=ON
    -DBUILD_WHEEL:BOOL=OFF
    -DNVIMG_CODEC_COPY_LIBS_TO_PYTHON_DIR:BOOL=OFF
    -DNVIMG_CODEC_PYTHON_VERSIONS=${PY_VER}
    -DNVIMG_CODEC_USE_SYSTEM_DLPACK:BOOL=ON
    -DNVIMG_CODEC_USE_SYSTEM_PYBIND:BOOL=ON
)

cmake ${CMAKE_ARGS} -GNinja "${nvimg_build_args[@]}" ${SRC_DIR}

cmake --build .

cmake --install . --strip

$PYTHON -m pip install --no-deps --no-build-isolation -v $SRC_DIR/build/python

ln -s $PREFIX/extensions $SP_DIR/nvidia/nvimgcodec/extensions
