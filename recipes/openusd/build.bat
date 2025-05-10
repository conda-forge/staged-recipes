mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DPXR_HEADLESS_TEST_MODE:BOOL=ON ^
    -DPXR_BUILD_IMAGING:BOOL=ON ^
    -DPXR_BUILD_USD_IMAGING=ON ^
    -DPXR_ENABLE_PYTHON_SUPPORT=ON ^
    -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY:BOOL=ON ^
    -DPXR_PYTHON_SHEBANG="/usr/bin/env python" ^
    -DPython3_EXECUTABLE=%PYTHON% ^
    -DPython_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
:: testWorkThreadLimits3 is disabled as it can fail on machines with few cores
:: testJsIO is disabled as it now actually links usd_tf, and so the linker remove the link to Python
ctest --output-on-failure -C Release -E "testWorkThreadLimits3|testJsIO"
if errorlevel 1 exit 1

:: The CMake install logic of openusd is not flexible, so let's fix the files
:: that should not be installed or should be installed in a different location

:: Python files should be moved from $CMAKE_INSTALL_PREFIX/lib/python/pxr to $SP_DIR/pxr
move "%LIBRARY_PREFIX%\lib\python\pxr" "%SP_DIR%\pxr"
if errorlevel 1 exit 1


:: All files installed in $CMAKE_INSTALL_PREFIX/tests, $CMAKE_INSTALL_PREFIX/share/usd/examples and $CMAKE_INSTALL_PREFIX/share/usd/tutorials can be removed
rd /s /q "%LIBRARY_PREFIX%\tests"
if errorlevel 1 exit 1

rd /s /q "%LIBRARY_PREFIX%\share\usd\examples"
if errorlevel 1 exit 1

rd /s /q "%LIBRARY_PREFIX%\share\usd\tutorials"
if errorlevel 1 exit 1

REM This logic is to ensure that pip list lists usd-core (https://pypi.org/project/usd-core/) as installed package
REM The version style is a bit different: openusd version are something like 22.01, 23.05, 24.11 while usd-core are 22.1, 23.5, 24.11
REM so we convert the first occurence of .0 to . if present, to convert from one style to another
set "PIP_USD_CORE_VERSION=%PKG_VERSION:.0=.%"

REM The METADATA file is necessary to ensure that pip list shows the pip package installed by conda
REM The INSTALLER file is necessary to ensure that pip list shows that the package is installed by conda
REM See https://packaging.python.org/specifications/recording-installed-packages/
REM and https://packaging.python.org/en/latest/specifications/core-metadata/#core-metadata

mkdir "%SP_DIR%/usd_core-%PIP_USD_CORE_VERSION%.dist-info"

set metadata_file=%SP_DIR%\usd_core-%PIP_USD_CORE_VERSION%.dist-info\METADATA
echo>%metadata_file% Metadata-Version: 2.1
echo>>%metadata_file% Name: usd-core
echo>>%metadata_file% Version: %PIP_USD_CORE_VERSION%
echo>>%metadata_file% Summary: Pixar's Universal Scene Description

set installer_file=%SP_DIR%\usd_core-%PIP_USD_CORE_VERSION%.dist-info\INSTALLER
echo>%installer_file% conda
