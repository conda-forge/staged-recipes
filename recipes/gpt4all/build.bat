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
    -DKOMPUTE_OPT_USE_BUILT_IN_VULKAN_HEADER=OFF ^
    -DKOMPUTE_OPT_USE_BUILT_IN_FMT=OFF
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1

REM Ensure spm-headers are available inside the python package to avoid pip metadata errors on Windows
if exist "..\gpt4all-backend\deps\llama.cpp-mainline\spm-headers" (
    if not exist "gpt4all-bindings\python\spm-headers" mkdir "gpt4all-bindings\python\spm-headers"
    xcopy /Y /E "..\gpt4all-backend\deps\llama.cpp-mainline\spm-headers\*" "gpt4all-bindings\python\spm-headers\" >nul
    if errorlevel 1 (
        echo Error copying spm-headers
        exit /b 1
    )
) else (
    echo Warning: spm-headers directory not found at ..\gpt4all-backend\deps\llama.cpp-mainline\spm-headers
)

pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
