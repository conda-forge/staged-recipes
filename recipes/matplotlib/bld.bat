mkdir lib
copy %LIBRARY_LIB%\zlibstatic.lib lib\z.lib
if errorlevel 1 exit 1
copy %LIBRARY_LIB%\libpng_static.lib lib\png.lib
if errorlevel 1 exit 1

set LIB=%LIBRARY_LIB%;.\lib
set LIBPATH=%LIBRARY_LIB%;.\lib
set INCLUDE=%LIBRARY_INC%

ECHO [directories] > setup.cfg
ECHO basedirlist = %PREFIX% >> setup.cfg
ECHO [packages] >> setup.cfg
ECHO tests = False >> setup.cfg
ECHO sample_data = False >> setup.cfg
ECHO toolkits_tests = False >> setup.cfg

if errorlevel 1 exit 1

python setup.py install
if errorlevel 1 exit 1


:: Anaconda seems to ship ActiveState's Tcl. We disable that behaviour. Ideally there would be a Tcl package upon which we can depend.
:: if "%ARCH%"=="64" (
::    set PLAT=win-amd64
::) else (
::    set PLAT=win32
::)
::
::copy C:\Tcl%ARCH%\bin\t*.dll %SP_DIR%\matplotlib-%PKG_VERSION%-py%PY_VER%-%PLAT%.egg\matplotlib\backends
