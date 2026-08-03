#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DBUILD_TESTS=OFF -DBUILD_WSI_XCB_SUPPORT=OFF -DBUILD_WSI_XLIB_SUPPORT=OFF -DBUILD_WSI_WAYLAND_SUPPORT=OFF .. 

cmake --build . --config Release
cmake --build . --config Release --target install
