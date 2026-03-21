mkdir cmake-build-local
cd cmake-build-local

cmake .. -G "Ninja" ^
    -DMVDIST_ONLY=True ^
    -DMVDPG_VERSION="%PKG_VERSION%" ^
    -DMV_PY_VERSION="%PY_VER%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    %CMAKE_ARGS%
if errorlevel 1 exit 1

cd ..
cmake --build cmake-build-local --config Release
if errorlevel 1 exit 1

"%PYTHON%" -m pip install . --no-deps --no-build-isolation
if errorlevel 1 exit 1
