mkdir build
cd build

cmake .. -G "Ninja" ^
    -DCMAKE_BUILD_TYPE="Release" ^
    -DPTHREAD_INCLUDE_DIRS:FILEPATH="%LIBRARY_PREFIX%/include" ^
    -DENABLE_SMESH=ON ^
    -DENABLE_NETGEN=ON ^
    -DENABLE_FORCE=ON

if errorlevel 1 exit 1
ninja install
if errorlevel 1 exit 1

cd ..
python setup.py install
