@echo on
setlocal EnableDelayedExpansion

mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake ../ -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release

if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release --parallel %NUMBER_OF_PRECESSOR%
if errorlevel 1 exit 1

popd