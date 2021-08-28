ECHO "hiredis library"

mkdir _build
cd _build
env

REM add future installation path to pkgconfig
set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;

cmake -G"NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DDISABLE_TESTS:BOOL=ON ^
      -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
      ..
if errorlevel 1 exit 1

nmake VERBOSE=1
if errorlevel 1 exit 1

nmake install VERBOSE=1
if errorlevel 1 exit 1
 
cd ..

