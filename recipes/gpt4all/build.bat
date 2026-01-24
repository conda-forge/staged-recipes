@echo on

git submodule update --init --recursive

pushd gpt4all-backend
if errorlevel 1 exit 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DLLMODEL_KOMPUTE=OFF ^
    -DLLMODEL_VULKAN=ON ^
    -DLLMODEL_CUDA=OFF ^
    -DLLMODEL_ROCM=OFF

if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1

pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
