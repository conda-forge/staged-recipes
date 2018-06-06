REM Install library with openPMDConfig.cmake files with cmake

mkdir build
cd build

cmake ^
    -G "NMake Makefiles"        ^
    -DCMAKE_BUILD_TYPE=Release  ^
    -DopenPMD_USE_MPI=OFF       ^
    -DopenPMD_USE_HDF5=ON       ^
    -DopenPMD_USE_ADIOS1=OFF    ^
    -DopenPMD_USE_ADIOS2=OFF    ^
    -DopenPMD_USE_PYTHON=ON     ^
    -DCMAKE_INSTALL_PREFIX=%PREFIX%  ^
    %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake test
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
