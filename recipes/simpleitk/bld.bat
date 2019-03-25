@echo on
set BUILD_DIR=%SRC_DIR%\b
mkdir %BUILD_DIR%
cd %BUILD_DIR%

echo "%SRC_DIR%"

REM Remove dot from PY_VER for use in library name
set MY_PY_VER=%PY_VER:.=%


REM Configure Step
cmake -G "Ninja" ^
    -D CMAKE_BUILD_TYPE:STRING=MinSizeRel ^
    -D "CMAKE_PROGRAM_PATH:PATH=%LIBRARY_PREFIX%" ^
    -D BUILD_SHARED_LIBS:BOOL=OFF ^
    -D BUILD_TESTING:BOOL=OFF ^
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON ^
    -D SimpleITK_PYTHON_USE_VIRTUALENV:BOOL=OFF ^
    -D "PYTHON_EXECUTABLE:FILEPATH=%PYTHON%" ^
    -D "PYTHON_INCLUDE_DIR:PATH=%PREFIX%/include" ^
    -D "PYTHON_LIBRARY:FILEPATH=%PREFIX%/libs/python%MY_PY_VER%.lib" ^
    "%SRC_DIR%/Wrapping/Python"

if errorlevel 1 (
   type CMakeFiles/CMakeOutput.log
   exit 1
)

REM Build step
cmake --build  . --config MinSizeRel
if errorlevel 1 (
   type CMakeCache.txt
   exit 1
)

REM Package step
cd SimpleITK-build\Wrapping\Python
%PYTHON% Packaging\setup.py install
