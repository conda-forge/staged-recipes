if not "%cuda_compiler_version%" == "None" (
    set USE_CUDA=1
) else (
    set USE_CUDA=0
)

pip install . --no-deps --no-build-isolation -vv
if %ERRORLEVEL% neq 0 exit 1
