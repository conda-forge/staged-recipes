mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DPHMAP_BUILD_TESTS=OFF ^
    -DPHMAP_BUILD_EXAMPLES=OFF ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1

REM Needs vcvars64.bat to be called
git submodule init
git submodule update --recursive
md build
cd build
COPY %TEMP%\dgl.dll .
cd ..\python
"%PYTHON%" setup.py install --single-version-externally-managed --record=record.txt || EXIT /B 1
EXIT /B