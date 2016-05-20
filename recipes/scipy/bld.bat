set COMP_DIR=C:\Program Files (x86)\IntelSWTools\compilers_and_libraries\windows

set DISTUTILS_USE_SDK=1
set MSSdk=1

if %PY_VER%==3.5 (
REM This one is essential for getting DLL linkage on Py3.5+
    set "PY_VCRUNTIME_REDIST=%LIBARARY_BIN%\vcruntime140.dll"
    set VS=vs2015
) else (
    set VS=vs2010
)

call "%COMP_DIR%\bin\ifortvars.bat" %INTEL_ARCH% %VS%

%PYTHON% setup.py install
if errorlevel 1 exit 1
