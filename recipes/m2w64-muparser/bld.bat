
:: remove sh.exe from PATH
set PATH=%PATH:C:\Program Files\Git\usr\bin;=%

@rem See https://bitbucket.org/dbarbier/ot-superbuild
copy "%RECIPE_DIR%\CMakeLists.txt" .
if errorlevel 1 exit 1

mkdir build_ && cd build_

cmake -G "MinGW Makefiles" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBUILD_SHARED_LIBS=ON ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%/mingw-w64" ^
  ..
if errorlevel 1 exit 1

mingw32-make install -j %CPU_COUNT%
if errorlevel 1 exit 1

start example1.exe
if errorlevel 1 exit 1
