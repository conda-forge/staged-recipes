@echo on

pushd gpt4all-backend
if errorlevel 1 exit 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DLLMODEL_KOMPUTE=ON ^
    -DLLMODEL_VULKAN=ON ^
    -DLLMODEL_CUDA=OFF ^
    -DLLMODEL_ROCM=OFF

if errorlevel 1 exit 1

cmake --build build --parallel 1
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1

pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
