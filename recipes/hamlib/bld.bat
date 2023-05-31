@echo on

copy "%RECIPE_DIR%\build.sh" .
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
FOR /F "delims=" %%i in ('cygpath.exe -u "%LIBRARY_PREFIX%"') DO set "PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%BUILD_PREFIX%"') DO set "BUILD_PREFIX=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SRC_DIR%"') DO set "SRC_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%RECIPE_DIR%"') DO set "RECIPE_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%PYTHON%"') DO set "PYTHON=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%SP_DIR%"') DO set "SP_DIR=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%PERL%"') DO set "PERL=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%LUA%"') DO set "LUA=%%i"
FOR /F "delims=" %%i in ('cygpath.exe -u "%LUA_INCLUDE_DIR%"') DO set "LUA_INCLUDE_DIR=%%i"
bash -lce "./build.sh"
if errorlevel 1 exit 1

:: Generate MSVC-compatible import library
pushd src
FOR /F %%i in ("%LIBRARY_PREFIX%/bin/libhamlib-*.dll") DO lib /def:libhamlib.def /name:%%~ni.dll /out:hamlib.lib /machine:x64
copy "hamlib.lib" "%LIBRARY_PREFIX%/lib/hamlib.lib"
popd
if errorlevel 1 exit 1

pushd c++
FOR /F %%i in ("%LIBRARY_PREFIX%/bin/libhamlib++-*.dll") DO lib /def:libhamlib++.def /name:%%~ni.dll /out:hamlib++.lib /machine:x64
copy "hamlib++.lib" "%LIBRARY_PREFIX%/lib/hamlib++.lib"
popd
if errorlevel 1 exit 1
