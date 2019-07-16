#!/bin/bash

set -euo pipefail
set -x

gn gen out.gn "--args=use_custom_libcxx=false clang_use_chrome_plugins=false v8_use_external_startup_data=false is_debug=false clang_base_path=\"${BUILD_PREFIX}\" mac_sdk_min=\"10.9\" use_system_xcode=false is_component_build=true mac_sdk_path=\"/opt/MacOSX10.9.sdk\" use_system_icu=true"
ninja -C out.gn

mkdir -p $PREFIX/lib
cp out.gn/libv8*${SHLIB_EXT} $PREFIX/lib
mkdir -p $PREFIX/include
cp -r include/* $PREFIX/include/
