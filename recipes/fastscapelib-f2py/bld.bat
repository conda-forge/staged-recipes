@echo on

set CFG=%USERPROFILE%\pydistutils.cfg
echo [config] > "%CFG%"
echo compiler=mingw32 >> "%CFG%"
echo [build] >> "%CFG%"
echo compiler=mingw32 >> "%CFG%"
echo [build_ext] >> "%CFG%"
echo compiler=mingw32 >> "%CFG%"

if exist %PREFIX%\Scripts\f2py.exe (
  set F2PY=%PREFIX%\Scripts\f2py.exe
) else (
  set F2PY=%PREFIX%\Scripts\f2py.bat
)

"%PYTHON%" setup.py build ^
           -G "MinGW Makefiles" ^
           -- ^
           -DF2PY_EXECUTABLE:FILEPATH="%F2PY%"

"%PYTHON%" setup.py install

if errorlevel 1 exit 1
