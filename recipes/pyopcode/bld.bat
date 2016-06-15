set BUILD_CONFIG=Release

REM tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

REM work in build subdir
cd pyopcode
mkdir build
cd build


cmake ../src -G "NMake Makefiles%" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%/include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DNUMPY_INCLUDE_DIR:PATH="%SP_DIR%/numpy/core/include" ^
    -DBOOST_ROOT:PATH="%PREFIX%/Library"

cd..

cmake --build ./build --target INSTALL --config %BUILD_CONFIG%

if %errorlevel% neq 0 exit /b %errorlevel%

copy .\build\release\_pyopcode.pyd "%PREFIX%\dlls\_pyopcode.pyd"
cd..

python setup.py bdist
python setup.py install
