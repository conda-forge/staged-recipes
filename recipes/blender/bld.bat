setlocal EnableDelayedExpansion
cmake -S . -B "%SRC_DIR%/../bl_build_folder" ^
    -C %SRC_DIR%/build_files/cmake/config/blender_release.cmake -G Ninja ^
    -DCMAKE_C_COMPILER=%CC% -DCMAKE_CXX_COMPILER=%CXX% -DCMAKE_BUILD_TYPE:STRING=release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1