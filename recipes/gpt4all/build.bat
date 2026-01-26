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

REM Ensure spm-headers exist and copy headers into the python package (search for ggml headers first)
set "SPM_DEST=gpt4all-bindings\python\spm-headers"
if not exist "%SPM_DEST%" mkdir "%SPM_DEST%"

REM Try to find ggml-alloc.h anywhere under llama.cpp-mainline
set "FOUND_HDR_DIR="
for /f "delims=" %%I in ('dir /s /b "..\gpt4all-backend\deps\llama.cpp-mainline\*ggml-alloc.h" 2^>nul') do (
    set "FOUND_HDR_DIR=%%~dpI"
    goto :found_ggml_headers
)

REM If not found by name, fall back to spm-headers dir if present
if exist "..\gpt4all-backend\deps\llama.cpp-mainline\spm-headers" (
    echo Using existing spm-headers directory to populate %SPM_DEST%
    xcopy /Y /E "..\gpt4all-backend\deps\llama.cpp-mainline\spm-headers\*" "%SPM_DEST%\" >nul
    if errorlevel 1 (
        echo Error copying spm-headers into python package
        exit /b 1
    )
) else (
    echo Warning: ggml headers not found under llama.cpp-mainline; python metadata build may fail
)

goto :after_spm_copy

:found_ggml_headers
echo Found ggml headers at %FOUND_HDR_DIR% - copying into %SPM_DEST%
xcopy /Y /E "%FOUND_HDR_DIR%*.h" "%SPM_DEST%\" >nul
if errorlevel 1 (
    echo Error copying ggml headers into python package
    exit /b 1
)

:after_spm_copy


pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
