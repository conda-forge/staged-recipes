set BUILD_CONFIG=Release

REM tell cmake where Python is
set PYTHON_LIBRARY=%CENV%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

cd samples\samplecode

mkdir build
cd build

cmake .. -G "NMake Makefiles" ^
    -Wno-dev ^
    -DPYTHON_INCLUDE_DIR:PATH="%CENV%/include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1
