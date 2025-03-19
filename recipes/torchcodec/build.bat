if not "%cuda_compiler_version%" == "None" (
    set USE_CUDA=1
) else (
    set USE_CUDA=0
)

:: We explicitly depend on lgpl's variant of ffmpeg in the recipe.yaml to ensure that
:: we do not have license violation due to linking a GPL project
set I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

pip install . --no-deps --no-build-isolation -vv
if %ERRORLEVEL% neq 0 exit 1
