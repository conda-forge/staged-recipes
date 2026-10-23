@echo off
setlocal EnableDelayedExpansion

cmake %CMAKE_ARGS% -S . -B build -G Ninja ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DARCH=x86-64 ^
  -DBUILD_TESTS=OFF ^
  -DBUILD_EXECUTABLES=OFF ^
  -DSTATIC_CURL=OFF ^
  -DSTATIC_MSVC_RUNTIME=OFF ^
  -DUSE_SYSTEM_DLIB=ON ^
  -DUSE_SYSTEM_GCEM=ON ^
  -DUSE_SYSTEM_BACKWARD=ON ^
  -DUSE_SYSTEM_CLI11=ON ^
  -DUSE_SYSTEM_THREADPOOL=OFF ^
  -DFETCHCONTENT_SOURCE_DIR_THREAD_POOL=%SRC_DIR%\thread-pool ^
  -DFETCHCONTENT_FULLY_DISCONNECTED=ON
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
