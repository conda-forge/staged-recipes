@echo On

if "%cuda_compiler_version%" == "None" (
    set DS_BUILD_OPS=0
) else (
    set DS_BUILD_OPS=1
)

:: Disable sparse_attn since it requires an exact version of triton==1.0.0
set DS_BUILD_SPARSE_ATTN=0

python -m pip install .
if errorlevel 1 exit 1
