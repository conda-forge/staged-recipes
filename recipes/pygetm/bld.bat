
(
echo [build_ext]
echo cmake_opts=-DPython3_EXECUTABLE="%PYTHON%" -DCMAKE_C_COMPILER=gcc -G "MinGW Makefiles"
echo compiler=gfortran
) > "%SRC_DIR%\python\setup.cfg"

set CFLAGS=-DMS_WIN64

python -m pip install --no-deps -v "%SRC_DIR%\python"
if errorlevel 1 exit /b 1

set BUILD_DIR=%SRC_DIR%\extern\pygsw\build
cmake -S "%SRC_DIR%\extern\pygsw" -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="%PYTHON%" -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_C_COMPILER=gcc -G "MinGW Makefiles"
if errorlevel 1 exit /b 1
cmake --build "%BUILD_DIR%" --target pygsw_wheel --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
xcopy /E /I "%BUILD_DIR%\pygsw" "%SP_DIR%\pygetm\pygsw"
if errorlevel 1 exit /b 1

set BUILD_DIR=%SRC_DIR%\extern\python-otps2\build
cmake -S "%SRC_DIR%\extern\python-otps2" -B "%BUILD_DIR%" -DCMAKE_BUILD_TYPE=Release -DPython3_EXECUTABLE="%PYTHON%" -DCMAKE_Fortran_COMPILER=gfortran -DCMAKE_C_COMPILER=gcc -G "MinGW Makefiles"
if errorlevel 1 exit /b 1
cmake --build "%BUILD_DIR%" --target otps2_wheel --config Release --parallel %CPU_COUNT%
if errorlevel 1 exit /b 1
xcopy /E /I "%BUILD_DIR%\otps2" "%SP_DIR%\pygetm\otps2"
