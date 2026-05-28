setlocal EnableDelayedExpansion

set "BUILD_DIR=build"

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"

if exist "%SRC_DIR%\osm2pgsql\contrib" rmdir /s /q "%SRC_DIR%\osm2pgsql\contrib"

cmake %CMAKE_ARGS% -S "%SRC_DIR%" ^
  -B "%BUILD_DIR%" ^
  -G "Ninja" ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D EXTERNAL_LIBOSMIUM=ON ^
  -D EXTERNAL_FMT=ON ^
  -D EXTERNAL_CLI11=ON ^
  -D EXTERNAL_PROTOZERO=ON ^
  -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

if errorlevel 1 exit /b 1

cmake --build "%BUILD_DIR%" --target all --parallel %CPU_COUNT%

if errorlevel 1 exit /b 1

cmake --install "%BUILD_DIR%"

if errorlevel 1 exit /b 1