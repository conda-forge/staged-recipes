mkdir build
cd build

REM Configure step
cmake -S . -B build  -G Ninja ^
 -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
 -DPYTHONOCC_BUILD_TYPE=Release ^
 -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
 -DCMAKE_SYSTEM_PREFIX_PATH="%LIBRARY_PREFIX%" ^
 -DPython3_FIND_STRATEGY=LOCATION ^
 -DPython3_FIND_REGISTRY=NEVER ^
 -DSWIG_HIDE_WARNINGS=ON ^

if errorlevel 1 exit 1
 cmake --build build -- install
if errorlevel 1 exit 1