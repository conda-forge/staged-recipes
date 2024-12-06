@echo on
REM Copyright (c) 2024, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
REM Licensed under the Apache License, Version 2.0 (the "License");

setlocal enabledelayedexpansion

mkdir build

cd build

set NVIMG_BUILD_ARGS= ^
    -DBUILD_DOCS:BOOL=OFF ^
    -DBUILD_SAMPLES:BOOL=OFF ^
    -DBUILD_TEST:BOOL=OFF

set NVIMG_LIBRARY_ARGS= ^
    -DBUILD_LIBRARY:BOOL=OFF ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DBUILD_STATIC_LIBS:BOOL=OFF ^
    -DWITH_DYNAMIC_NVJPEG:BOOL=ON ^
    -DWITH_DYNAMIC_NVJPEG2K:BOOL=OFF

set NVIMG_EXT_ARGS= ^
    -DBUILD_EXTENSIONS:BOOL=OFF ^
    -DBUILD_NVJPEG_EXT:BOOL=OFF ^
    -DBUILD_NVJPEG2K_EXT:BOOL=OFF ^
    -DBUILD_NVBMP_EXT:BOOL=OFF ^
    -DBUILD_NVPNM_EXT:BOOL=OFF ^
    -DBUILD_LIBJPEG_TURBO_EXT:BOOL=OFF ^
    -DBUILD_LIBTIFF_EXT:BOOL=OFF ^
    -DBUILD_OPENCV_EXT:BOOL=OFF

set NVIMG_PYTHON_ARGS= ^
    -DBUILD_PYTHON:BOOL=ON ^
    -DNVIMG_CODEC_PYTHON_VERSIONS=%PY_VER% ^
    -DBUILD_WHEEL:BOOL=OFF ^
    -DNVIMG_CODEC_COPY_LIBS_TO_PYTHON_DIR:BOOL=OFF ^
    -DNVIMG_CODEC_USE_SYSTEM_PYBIND:BOOL=ON ^
    -DNVIMG_CODEC_USE_SYSTEM_DLPACK:BOOL=ON

cmake %CMAKE_ARGS% -GNinja -DCMAKE_INSTALL_PREFIX="%PREFIX%/Library" ^
    %NVIMG_BUILD_ARGS% %NVIMG_LIBRARY_ARGS% %NVIMG_EXT_ARGS% ^
    %NVIMG_PYTHON_ARGS% %SRC_DIR%

cmake --build .

cmake --install .

@REM copy in CMakeLists doesn't work for unknown reason
move .\python\nvimgcodec*.pyd .\python\nvidia\nvimgcodec\

%PYTHON% -m pip install .\python --no-deps --no-build-isolation -v

endlocal
