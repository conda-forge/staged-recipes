echo ON

mkdir build
cd build

cmake -G "Ninja" ^
      %CMAKE_ARGS% ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DCMAKE_INCLUDE_PATH="%INCLUDE_INC%" ^
      -DBUILD_PLUGIN_E57=OFF ^
      -DBUILD_PLUGIN_PGPOINTCLOUD=OFF ^
      -DBUILD_PLUGIN_ARROW=OFF ^
      -DBUILD_PLUGIN_DRACO=OFF ^
      -DENABLE_CTEST=OFF ^
      -DWITH_TESTS=OFF ^
      -DWITH_ZLIB=ON ^
      -DWITH_ZSTD=ON ^
      -DZSTD_LIBRARY="%LIBRARY_LIB%\libzstd.lib" ^
      ..
if errorlevel 1 exit 1

ninja -j%CPU_COUNT%
if %ERRORLEVEL% neq 0 exit 1

ninja install
if %ERRORLEVEL% neq 0 exit 1

set ACTIVATE_DIR=%PREFIX%\etc\conda\activate.d
set DEACTIVATE_DIR=%PREFIX%\etc\conda\deactivate.d
mkdir %ACTIVATE_DIR%
mkdir %DEACTIVATE_DIR%

copy %RECIPE_DIR%\scripts\activate.bat %ACTIVATE_DIR%\pdal-activate.bat
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.bat %DEACTIVATE_DIR%\pdal-deactivate.bat
if errorlevel 1 exit 1

:: Copy unix shell activation scripts, needed by Windows Bash users
copy %RECIPE_DIR%\scripts\activate.sh %ACTIVATE_DIR%\pdal-activate.sh
if errorlevel 1 exit 1

copy %RECIPE_DIR%\scripts\deactivate.sh %DEACTIVATE_DIR%\pdal-deactivate.sh
if errorlevel 1 exit 1
