@echo on

pushd gpt4all-backend
if errorlevel 1 exit 1

cmake -S . -B build -G "NMake Makefiles JOM" ^
    %CMAKE_ARGS% ^
    -DLLMODEL_KOMPUTE=ON ^
    -DLLMODEL_VULKAN=OFF ^
    -DLLMODEL_CUDA=OFF ^
    -DLLMODEL_ROCM=OFF ^
    -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON ^
    -DKOMPUTE_OPT_USE_SPDLOG=ON ^
    -DKOMPUTE_OPT_USE_BUILT_IN_SPDLOG=OFF ^
    -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF ^
    -DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF
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
