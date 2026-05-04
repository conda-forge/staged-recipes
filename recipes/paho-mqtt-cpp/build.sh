#!/usr/bin/env bash
set -euo pipefail

cmake ${CMAKE_ARGS} \
    -Bbuild \
    -H. \
    -DPAHO_WITH_MQTT_C=OFF \
    -DPAHO_WITH_SSL=ON \
    -DPAHO_BUILD_SHARED=ON \
    -DPAHO_BUILD_STATIC=OFF \
    -DPAHO_BUILD_DOCUMENTATION=OFF \
    -DPAHO_BUILD_SAMPLES=OFF \
    -DPAHO_BUILD_TESTS=OFF

cmake --build build --target install
