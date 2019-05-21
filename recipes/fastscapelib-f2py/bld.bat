:: correct FC, apparently pointed to host prefix??
set FC=%BUILD_PREFIX%\Library\bin\flang.exe

if exist %PREFIX%\Scripts\f2py.exe (
set F2PY=%PREFIX%\Scripts\f2py.exe
) else (
set F2PY=%PREFIX%\Scripts\f2py.bat
)

"%PYTHON%" -m pip install . --no-build-isolation --no-deps --ignore-installed --no-cache-dir -vvv

if errorlevel 1 exit 1
