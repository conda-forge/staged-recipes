@echo on

:: Update PATH to ensure mingw compiler is not found
pushd %~dp0
call rmpath C:\\Program Files\\Git\\mingw64\\bin
call rmpath C:\\ProgramData\\Chocolatey\\bin
call rmpath C:\\Strawberry\\c\\bin
popd

if exist %PREFIX%\Scripts\f2py.exe (
  set F2PY=%PREFIX%\Scripts\f2py.exe
) else (
  set F2PY=%PREFIX%\Scripts\f2py.bat
)

set FC="%BUILD_PREFIX%\Library\bin\flang.exe"

mkdir "%SRC_DIR%\dist"

"%PYTHON%" setup.py bdist_wheel --dist-dir="%SRC_DIR%\dist" -- ^
           -DCMAKE_Fortran_COMPILER:FILEPATH="%FC%" ^
           -DF2PY_EXECUTABLE:FILEPATH="%F2PY%"

"%PYTHON%" -m pip install ^
           --no-index ^
           --find-links="%SRC_DIR%\dist" ^
           fastscapelib_fortran ^
           -vvv

if errorlevel 1 exit 1
