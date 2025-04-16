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

cmake_minimum_required(VERSION 3.12)

project(all_headers VERSION 0.1 LANGUAGES C CXX CUDA)

find_package(nvimgcodec REQUIRED)
find_package(CUDAToolkit REQUIRED COMPONENT cudart)

set(ALL_TARGETS
    nvimgcodec::nvimgcodec
    CUDA::cudart
)

add_executable(c_all_headers all_headers.c)
target_link_libraries(c_all_headers PUBLIC ${ALL_TARGETS})

add_executable(cxx_all_headers all_headers.cxx)
target_link_libraries(cxx_all_headers PUBLIC ${ALL_TARGETS})

include(GNUInstallDirs)
install(TARGETS c_all_headers cxx_all_headers RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
