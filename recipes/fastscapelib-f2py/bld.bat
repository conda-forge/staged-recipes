@echo on

if exist %PREFIX%\Scripts\f2py.exe (
  set F2PY=%PREFIX%\Scripts\f2py.exe
) else (
  set F2PY=%PREFIX%\Scripts\f2py.bat
)

"%PYTHON%" setup.py bdist_wheel --dist-dir=dist -- ^
           -DCMAKE_Fortran_COMPILER:FILEPATH="%BUILD_PREFIX%\Library\bin\flang.exe" ^
           -DF2PY_EXECUTABLE:FILEPATH="%F2PY%"

"%PYTHON%" -m pip install fastscapelib_fortran ^
           --no-index ^
           --find-links=dist/ ^
           --no-deps ^
           --ignore-installed ^
           --no-cache-dir ^
           -vvv

if errorlevel 1 exit 1
