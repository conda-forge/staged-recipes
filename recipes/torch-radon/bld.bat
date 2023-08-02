@echo on

set TORCH_CUDA_ARCH_LIST="3.5 3.7 5.0 5.2 5.3 6.0 6.1 6.2 7.0 7.2 7.5 8.0 8.6+PTX"
if errorlevel 1 exit /b 1

%PYTHON% -m pip install . -vv --no-deps
if errorlevel 1 exit /b 1
