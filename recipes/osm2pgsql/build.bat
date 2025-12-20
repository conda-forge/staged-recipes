setlocal EnableDelayedExpansion

set BUILD_DIR=build

cd %SRC_DIR%

if exist %BUILD_DIR% rmdir /s /q %BUILD_DIR%
mkdir %BUILD_DIR%

if exist osm2pgsql\contrib rmdir /s /q osm2pgsql\contrib

cmake -S osm2pgsql ^
 -B %BUILD_DIR% ^
 -G "Ninja" ^
 -D CMAKE_BUILD_TYPE=Release ^
 -D EXTERNAL_LIBOSMIUM=ON ^
 -D EXTERNAL_FMT=ON ^
 -D EXTERNAL_CLI11=ON ^
 -D EXTERNAL_PROTOZERO=ON ^
 -D OSMIUM_INCLUDE_DIR=libosmium\include ^
 -D PROTOZERO_INCLUDE_DIR=protozero\include ^
 -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

cmake --build %BUILD_DIR% --target all

if errorlevel 1 exit 1

cmake --build %BUILD_DIR% --target install

if errorlevel 1 exit 1
