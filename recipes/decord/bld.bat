@echo off

setlocal EnableDelayedExpansion

if exist 3rdparty\dmlc-core rmdir /s /q 3rdparty\dmlc-core
if exist 3rdparty\dlpack rmdir /s /q 3rdparty\dlpack

if not exist build mkdir build
cd build

cmake -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DUSE_CUDA=OFF ^
    -DBUILD_EXAMPLES=OFF ^
    ..

cmake --build . --config Release
cmake --install . --config Release

cd ..

cd python
%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
cd ..
