#!/bin/bash

set -exo pipefail

# Remove existing imgui and implot headers to use the external ones installed by their Conda packages
rm include/vsgImGui/imgui.h
rm include/vsgImGui/implot.h

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DVSG_IMGUI_USE_SYSTEM_IMGUI=ON \
  -DVSG_IMGUI_USE_SYSTEM_IMPLOT=ON

cmake --build build --parallel

cmake --install build --strip
