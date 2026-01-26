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

REM Ensure spm-headers exist and copy headers into the python package (search for ggml headers under %SRC_DIR% first)
set "SPM_DEST=gpt4all-bindings\python\spm-headers"
if not exist "%SPM_DEST%" mkdir "%SPM_DEST%"


@REM Prefer absolute SRC_DIR path if available
if defined SRC_DIR (
    set "SEARCH_BASE=%SRC_DIR%\gpt4all-backend\deps\llama.cpp-mainline"
) else (
    set "SEARCH_BASE=..\gpt4all-backend\deps\llama.cpp-mainline"
)

@REM First, copy from ggml include if present
if exist "%SEARCH_BASE%\ggml\include" (
    echo Copying ggml headers from %SEARCH_BASE%\ggml\include to %SPM_DEST%
    xcopy /Y /E "%SEARCH_BASE%\ggml\include\*.h" "%SPM_DEST%\" >nul
    if errorlevel 1 (
        echo Error copying ggml include headers
        exit /b 1
    )
) else (
    REM Fallback: search recursively for ggml-alloc.h anywhere under SEARCH_BASE
    set "FOUND_HDR_DIR="
    for /f "delims=" %%I in ('dir /s /b "%SEARCH_BASE%\*ggml-alloc.h" 2^>nul') do (
        set "FOUND_HDR_DIR=%%~dpI"
        goto :found_ggml_headers
    )

    if defined FOUND_HDR_DIR goto :found_ggml_headers

    REM If still not found, try spm-headers directory
    if exist "%SEARCH_BASE%\spm-headers" (
        echo Using existing spm-headers directory to populate %SPM_DEST%
        xcopy /Y /E "%SEARCH_BASE%\spm-headers\*" "%SPM_DEST%\" >nul
        if errorlevel 1 (
            echo Error copying spm-headers into python package
            exit /b 1
        )
    ) else (
        echo Warning: ggml headers not found under %SEARCH_BASE%; python metadata build may fail
    )
)

goto :after_spm_copy

:found_ggml_headers
echo Found ggml headers at %FOUND_HDR_DIR% - copying into %SPM_DEST%
xcopy /Y /E "%FOUND_HDR_DIR%\*.h" "%SPM_DEST%\" >nul
if errorlevel 1 (
    echo Error copying ggml headers into python package
    exit /b 1
)

:after_spm_copy

REM Ensure compatibility with packaging scripts that expect headers under the llama.cpp tree
if not exist "%SEARCH_BASE%\spm-headers\ggml-alloc.h" (
    echo Copying ggml headers from %SPM_DEST% to %SEARCH_BASE%\spm-headers for setup.py compatibility
    if not exist "%SEARCH_BASE%\spm-headers" mkdir "%SEARCH_BASE%\spm-headers"
    xcopy /Y /E "%SPM_DEST%\*" "%SEARCH_BASE%\spm-headers\" >nul
    if errorlevel 1 (
        echo Error copying ggml headers into %SEARCH_BASE%\spm-headers
        exit /b 1
    )
)

REM Verify ggml-alloc.h is present in %SPM_DEST%, fail early if not
if not exist "%SPM_DEST%\ggml-alloc.h" (
    echo ERROR: ggml-alloc.h not found in %SPM_DEST%; cannot continue
    dir "%SPM_DEST%" /b
    dir "%SEARCH_BASE%" /b
    exit /b 1
) else (
    echo ggml-alloc.h found in %SPM_DEST%
)


pushd gpt4all-bindings\python
if errorlevel 1 exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1

popd
if errorlevel 1 exit 1
