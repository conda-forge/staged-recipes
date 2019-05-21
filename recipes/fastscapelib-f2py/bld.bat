:: correct FC, apparently pointed to host prefix??
set FC=%BUILD_PREFIX%\Library\bin\flang.exe

echo %PREFIX%\Scripts
ls %PREFIX%\Scripts
echo %SCRIPTS%


if exist %SCRIPTS%\f2py.exe (
  set F2PY=%SCRIPTS%\f2py.exe
) else (
  set F2PY=%SCRIPTS%\f2py.bat
)

"%PYTHON%" -m pip install . --no-build-isolation --no-deps --ignore-installed --no-cache-dir -vvv

if errorlevel 1 exit 1
