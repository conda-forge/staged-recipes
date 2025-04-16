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
    -DCUDA_TARGET_ARCHS=${CUDAARCHS}
# Library args
    -DBUILD_LIBRARY:BOOL=ON
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_STATIC_LIBS:BOOL=OFF
# "DYNAMIC_LINK" means using dlopen, but we want to link to shared libraries.
    -DWITH_DYNAMIC_LINK:BOOL=OFF
# Extension args
    -DBUILD_EXTENSIONS:BOOL=ON
    -DBUILD_LIBJPEG_TURBO_EXT:BOOL=ON
    -DBUILD_LIBTIFF_EXT:BOOL=ON
    -DBUILD_NVBMP_EXT:BOOL=ON
    -DBUILD_NVJPEG_EXT:BOOL=ON
    -DBUILD_NVJPEG2K_EXT:BOOL=ON
    -DBUILD_NVPNM_EXT:BOOL=ON
    -DBUILD_NVTIFF_EXT:BOOL=ON
    -DBUILD_OPENCV_EXT:BOOL=ON
# Python args
    -DPython_EXECUTABLE=$PYTHON
    -DBUILD_PYTHON:BOOL=OFF
    -DPYTHON_VERSIONS="${PY_VER}"
    -DBUILD_WHEEL:BOOL=OFF
    -DNVIMGCODEC_COPY_LIBS_TO_PYTHON_DIR:BOOL=OFF
    -DNVIMGCODEC_BUILD_PYBIND11:BOOL=OFF
    -DNVIMGCODEC_BUILD_DLPACK:BOOL=OFF
)

cmake ${CMAKE_ARGS} -GNinja "${nvimg_build_args[@]}" ${SRC_DIR}

cmake --build .

cmake --install . --strip

rm $PREFIX/LICENSE.txt
rm $PREFIX/Acknowledgements.txt

# The default search path for nvimgcodec plugins is $PREFIX/lib/extensions
# Can also be overridden by env variable NVIMGCODEC_EXTENSIONS_PATH or in source code
mv -v $PREFIX/extensions $PREFIX/lib/extensions
sed -i 's|"${_PACKAGE_ROOTDIR}/extensions"|"${_PACKAGE_ROOTDIR}/lib/extensions"|g' $PREFIX/lib/cmake/nvimgcodec/nvimgcodecConfig.cmake
