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

set -e

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja \
    -DBUILD_LIBRARY:BOOL=ON \
    -DBUILD_DOCS:BOOL=OFF \
    -DBUILD_EXTENSIONS:BOOL=OFF \
    -DBUILD_PYTHON:BOOL=OFF \
    -DBUILD_SAMPLES:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_STATIC_LIBS:BOOL=OFF \
    -DBUILD_TEST:BOOL=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_NVJPEG2K_EXT:BOOL=OFF \
    -DBUILD_NVJPEG_EXT:BOOL=ON \
    ${SRC_DIR}

cmake --build .

cmake --install . --strip

# Move cmake configure files to the more-common lib directory
mkdir -p ${PREFIX}/lib/cmake
mv ${PREFIX}/cmake/* ${PREFIX}/lib/cmake
