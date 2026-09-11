@echo off

cmake -GNinja ^
  %CMAKE_ARGS% ^
  -DBUILD_SHARED_LIBS=ON ^
  -DUSE_MSVC_RUNTIME_LIBRARY_DLL=ON ^
  -DBUILD_CLOUD_CLIENT=OFF -DBUILD_TESTS=OFF ^
  -S src ^
  -B build_dir
if %errorlevel% neq 0 exit  %errorlevel%
cmake --build build_dir --config Release -j 4
if %errorlevel% neq 0 exit  %errorlevel%
cmake --build build_dir --config Release --target install
if %errorlevel% neq 0 exit  %errorlevel%
