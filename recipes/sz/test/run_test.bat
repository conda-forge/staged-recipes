@echo on

cmake -S test -B build-test -G Ninja %CMAKE_ARGS% -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
cmake --build build-test
if errorlevel 1 exit 1
cd build-test
test_sz3.exe
if errorlevel 1 exit 1
test_h5z.exe
if errorlevel 1 exit 1

:: HDF5 has no default plugin directory on Windows.
set "HDF5_PLUGIN_PATH=%PREFIX%\lib\hdf5\plugin"
h5repack -f UD=32024,0 plain.h5 repacked.h5
if errorlevel 1 exit 1
h5dump -pH repacked.h5 > dump.txt
if errorlevel 1 exit 1
type dump.txt
findstr 32024 dump.txt
if errorlevel 1 exit 1
h5repack -f NONE repacked.h5 restored.h5
if errorlevel 1 exit 1
h5diff -d 1e-3 plain.h5 restored.h5
if errorlevel 1 exit 1
