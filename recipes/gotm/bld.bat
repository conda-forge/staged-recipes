mkdir build
cmake -B build -S %SRC_DIR% -G "MinGW Makefiles" -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX%
if errorlevel 1 exit 1
cmake --build build --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit 1
mkdir %PREFIX%\bin
copy build\gotm.exe %PREFIX%\bin\
if errorlevel 1 exit 1
rmdir /S /Q build
