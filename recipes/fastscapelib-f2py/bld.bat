@echo on

if exist %PREFIX%\Scripts\f2py.exe (
  set F2PY=%PREFIX%\Scripts\f2py.exe
) else (
  set F2PY=%PREFIX%\Scripts\f2py.bat
)

mkdir "%SRC_DIR%\dist"

"%PYTHON%" setup.py build ^
           --compiler=mingw32 ^
           -G "MinGW Makefiles" ^
           -- ^
           -DF2PY_EXECUTABLE:FILEPATH="%F2PY%"

"%PYTHON%" setup.py install

if errorlevel 1 exit 1
