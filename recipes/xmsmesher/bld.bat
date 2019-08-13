
copy %RECIPE_DIR%\condabuildinfo.cmake .

if not exist "build\" mkdir build
cd build

%BUILD_PREFIX%\Library\bin\cmake.exe -G "NMake Makefiles" ^
        -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DIS_CONDA_BUILD=True ^
        -DCONDA_PREFIX=%CONDA_PREFIX% ^
        -DIS_PYTHON_BUILD=True ^
        -DPYTHON_TARGET_VERSION=%PY_VER% ^
        -DPYTHON_SITE_PACKAGES=%SP_DIR% ^
        -DBOOST_ROOT=%BUILD_PREFIX%\Library ^
        -DBoost_NO_SYSTEM_PATHS=True ^
        -DXMS_VERSION="%XMS_VERSION%" %SRC_DIR%

nmake -f Makefile
nmake install -f Makefile

cd ..
copy .\build\_xms*.pyd .\_package\xms\mesher
dir .\_package\xms\mesher

%PYTHON% --version
%PYTHON% -m pip install .\_package --no-deps --ignore-installed -vvv
