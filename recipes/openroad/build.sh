#!/bin/bash
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -ex

cd $SRC_DIR
cmake -B build -DTCL_LIB_PATHS="$BUILD_PREFIX;$PREFIX" -DCMAKE_FIND_ROOT_PATH="$BUILD_PREFIX;$PREFIX" -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=ONLY -DUSE_SYSTEM_BOOST=ON -DENABLE_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$PREFIX .
cmake --build build -j $CPU_COUNT --target install
