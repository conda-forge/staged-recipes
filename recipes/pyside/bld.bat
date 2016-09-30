rem  @echo off

set CMAKE_CONFIG="Release"

cd %SRC_DIR%\sources\shiboken

mkdir build
cd build

set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_FIND_ROOT_PATH="%LIBRARY_PREFIX%"                ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_SITE_PACKAGES="%SP_DIR%"                        ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=OFF                                        ^
    -DUSE_PYTHON3=%PY3K%                                     ^
    -DPYTHON3_EXECUTABLE="%PYTHON%"                          ^
    -DPYTHON3_INCLUDE_DIR="%PREFIX%\include"                 ^
    -DPYTHON3_LIBRARY="%PYTHON_LIBRARY%"                     ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

cd %SRC_DIR%\sources\pyside

mkdir build
cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_FIND_ROOT_PATH="%LIBRARY_PREFIX%"                ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DSITE_PACKAGE="%SP_DIR%"                                ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    -DBUILD_TESTS=ON                                         ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target INSTALL
if errorlevel 1 exit 1

ctest --output-on-failure --timeout 100
if errorlevel 1 exit 1
