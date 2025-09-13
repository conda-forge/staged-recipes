mkdir build
cd build

cmake %CMAKE_ARGS% -G "Ninja" ^
    -DBUILD_TESTING:BOOL=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    %SRC_DIR%
if errorlevel 1 exit 1

type CMakeCache.txt

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release
if errorlevel 1 exit 1

REM The METADATA file is necessary to ensure that pip list shows the pip package installed by conda
REM The INSTALLER file is necessary to ensure that pip list shows that the package is installed by conda
REM See https://packaging.python.org/specifications/recording-installed-packages/
REM and https://packaging.python.org/en/latest/specifications/core-metadata/#core-metadata

mkdir "%SP_DIR%/placo-%PKG_VERSION%.dist-info"

set metadata_file=%SP_DIR%\placo-%PKG_VERSION%.dist-info\METADATA
echo>%metadata_file% Metadata-Version: 2.1
echo>>%metadata_file% Name: placo
echo>>%metadata_file% Version: %PKG_VERSION%
echo>>%metadata_file% Summary: Rhoban Planning and Control

set installer_file=%SP_DIR%\placo-%PKG_VERSION%.dist-info\INSTALLER
echo>%installer_file% conda

