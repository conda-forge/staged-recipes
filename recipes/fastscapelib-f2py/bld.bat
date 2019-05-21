:: correct FC, apparently pointed to host prefix??
set FC=%BUILD_PREFIX%\Library\bin\flang.exe

ls %PREFIX%\bin

if exist %PREFIX%\bin\f2py.exe (
  set F2PY=%PREFIX%\bin\f2py.exe
) else (
  set F2PY=%PREFIX%\bin\f2py.bat
)

"%PYTHON%" -m pip install . --no-build-isolation --no-deps --ignore-installed --no-cache-dir -vvv

if errorlevel 1 exit 1
