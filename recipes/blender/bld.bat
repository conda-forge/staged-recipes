setlocal EnableDelayedExpansion

set BUILD_DIR="%SRC_DIR%/../bl_build_folder"
cmake -S . -B %BUILD_DIR% ^
    -C %SRC_DIR%/build_files/cmake/config/blender_release.cmake -G Ninja ^
    -DCMAKE_C_COMPILER=%CC% -DCMAKE_CXX_COMPILER=%CXX% -DCMAKE_BUILD_TYPE:STRING=release -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

cmake --build %BUILD_DIR% --target install
if errorlevel 1 exit 1
