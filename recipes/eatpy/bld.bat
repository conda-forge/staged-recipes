set FFLAGS=-fno-range-check
set CFLAGS=-DMS_WIN64
REM -DCMAKE_C_COMPILER=gcc -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_CXX_COMPILER=gcc 
cmake -S "%SRC_DIR%" -B build -DPython3_EXECUTABLE="%PYTHON%" -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%PREFIX%" %CMAKE_ARGS%
REM -DCMAKE_C_COMPILER=gcc -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_CXX_COMPILER=g++ 
REM cmake -S "%SRC_DIR%" -B build -DPython3_EXECUTABLE="%PYTHON%" -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="%PREFIX%" %CMAKE_ARGS% -DCMAKE_Fortran_COMPILER=gfortran
if errorlevel 1 exit 1
cmake --build build --config Release --parallel %CPU_COUNT% --target install
if errorlevel 1 exit 1
rmdir /S /Q build
