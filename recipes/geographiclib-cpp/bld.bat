mkdir build
cd build

cmake -G "NMake Makefiles" ^
    -DGEOGRAPHICLIB_LIB_TYPE=SHARED ^
    -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
    -DCMAKE_INCLUDE_PATH="%CONDA_PREFIX%/include" ^
    -DCMAKE_LIBRARY_PATH="%CONDA_PREFIX%/lib" ^
    ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
