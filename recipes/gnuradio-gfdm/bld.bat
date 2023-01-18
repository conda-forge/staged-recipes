setlocal EnableDelayedExpansion
@echo on

cd commpy
if errorlevel 1 exit 1
pip install --no-deps .
if errorlevel 1 exit 1
cd ..
if errorlevel 1 exit 1

cd gr-gfdm
if errorlevel 1 exit 1
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE:PATH="%PYTHON%" ^
    -DENABLE_DOXYGEN=OFF ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1
