#!/bin/bash

cmake -DCOMPONENT="library" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenMS_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="OpenSwathAlgo_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="thirdparty_headers" -P build/cmake_install.cmake
cmake -DCOMPONENT="share" -P build/cmake_install.cmake
cmake -DCOMPONENT="cmake" -P build/cmake_install.cmake
