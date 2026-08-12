
setlocal EnableDelayedExpansion 
:: Enable output of commands executed to make script debugging easier.
@echo on

:: Setup user config
set "build_threads=%FLAMEGPU_CONDA_BUILD_THREADS%"
if "%build_threads%" == "" set "build_threads=1"

set "build_arch="
if not "%FLAMEGPU_CONDA_CUDA_ARCHITECTURES%" == "" (
  set "build_arch=-DCMAKE_CUDA_ARCHITECTURES=%FLAMEGPU_CONDA_CUDA_ARCHITECTURES%"
)

mkdir build 2>nul
cd build

:: Configure CMake
cmake .. -DFLAMEGPU_BUILD_PYTHON=ON -DFLAMEGPU_BUILD_PYTHON_VENV=OFF -DFLAMEGPU_BUILD_ALL_EXAMPLES=OFF -DFLAMEGPU_BUILD_PYTHON_CONDA=ON %build_arch% %CMAKE_ARGS% -DPython3_FIND_VIRTUALENV=ONLY -DPython3_ROOT_DIR="%BUILD_PREFIX%" -DPython3_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit /b 1

:: Build Python wheel
cmake --build . --config Release --target pyflamegpu --parallel %build_threads%
if errorlevel 1 exit /b 1

:: Install built wheel
for /r "lib\Release\python\dist" %%f in (pyflamegpu*.whl) do (
    set "pyfgpu_wheel=%%~f"
    goto :found_pyfgpu_wheel
)

:found_pyfgpu_wheel
%PYTHON% -m pip install --no-deps %pyfgpu_wheel%

:: Cleanup
cd ..
rmdir /s /q build

if errorlevel 1 exit 1