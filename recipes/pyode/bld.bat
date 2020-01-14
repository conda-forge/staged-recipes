ECHO "stage 1, library"
REM setlocal EnableDelayedExpansion

mkdir _build
cd _build

REM add future installation path to pkgconfig
set PKG_CONFIG_PATH=%LIBRARY_PREFIX%\lib\pkgconfig;

cmake -G"NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DODE_WITH_DEMOS:BOOL=OFF ^
      -DODE_WITH_TESTS:BOOL=OFF ^
      -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH:PATH=%LIBRARY_PREFIX% ^
      ..
if errorlevel 1 exit 1

nmake VERBOSE=1
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
 
cd ..

ECHO "stage 2, bindings"
cd bindings\python

ECHO "check pkgconfig output"
pkg-config --cflags ode
pkg-config --libs ode
ECHO "PKG_CONFIG_PATH %PKG_CONFIG_PATH%"
set PATH=%PATH%:%LIBRARY_PREFIX%\bin

%PYTHON% setup.py install --root %PREFIX% --prefix ""
if errorlevel 1 exit 1
REM --root %PREFIX% --prefix ""
