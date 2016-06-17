set BUILD_CONFIG=Release

REM tell cmake where Python is
set PYTHON_LIBRARY=%PREFIX%\libs\python%PY_VER:~0,1%%PY_VER:~2,1%.lib

REM work in build subdir
cd pyopcode
mkdir build
cd build

cmake ../src -G "NMake Makefiles" ^
    -Wno-dev ^
    -DCMAKE_BUILD_TYPE=%BUILD_CONFIG% ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DPYTHON_INCLUDE_DIR:PATH="%PREFIX%/include" ^
    -DPYTHON_LIBRARY:FILEPATH="%PYTHON_LIBRARY%" ^
    -DNUMPY_INCLUDE_DIR:PATH="%SP_DIR%/numpy/core/include" ^
    -DBOOST_ROOT:PATH="%PREFIX%/Library"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

REM The file get's created in the current directory
copy .\_pyopcode.pyd "%PREFIX%\dlls\_pyopcode.pyd"
if errorlevel 1 exit 1

REM We have to CD twice, because we're still inside build
cd..
cd..

python setup.py bdist
python setup.py install
exit 0
