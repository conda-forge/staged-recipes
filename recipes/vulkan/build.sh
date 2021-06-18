#!/usr/bin/env bash

cd VulkanTools
mkdir build
./update_external_sources.sh
cd build
../scripts/update_deps.py
cmake -C helper.cmake ..
cmake --build . --parallel