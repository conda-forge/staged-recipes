rmdir /S /Q build_proxqp
mkdir build_proxqp
cd build_proxqp

:: proxqp requires clang-cl on VS2019,
:: see https://github.com/conda-forge/proxsuite-feedstock/blob/f72cea3da7297181ce0ff8733dd998b5bd675d02/recipe/bld.bat#L4
set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"

cmake %CMAKE_ARGS% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    %SRC_DIR%\plugins\proxqp
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
