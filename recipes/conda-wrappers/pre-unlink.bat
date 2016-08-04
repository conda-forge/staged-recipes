@set "CREATE_WRAPPERS_COMMAND=create-wrappers"

@if "%PKG_NAME%" == "conda-wrappers" (
    rem It is a conda build environment or it is being installed with
    rem "conda install -n env_name conda-wrappers"
    @set "ENV_DIR=%PREFIX%"
    rem In this case the environment is not always properly activated, so
    rem create-wrappers will not be on PATH
    @set "CREATE_WRAPPERS_COMMAND=%PREFIX%\Scripts\create-wrappers"
) else if not "%CONDA_PREFIX%" == "" (
    rem Regular env on newer conda versions
    @set "ENV_DIR=%CONDA_PREFIX%"
) else if not "%CONDA_DEFAULT_ENV%" == "" (
    rem variable that is set on older conda versions
    @set "ENV_DIR=%CONDA_DEFAULT_ENV%"
) else if not "%CONDA_ENV_PATH%" == "" (
    rem variable that is set on older conda versions
    @set "ENV_DIR=%CONDA_ENV_PATH%"
) else (
    @for /F %%i in ('conda info --root') do @set "ENV_DIR=%%i"
    @echo None of CONDA_PREFIX, CONDA_DEFAULT_ENV, CONDA_ENV_PATH are set. Assuming conda root env > %ENV_DIR%\.messages.txt
)

@set "WRAPPERS_DIR=%ENV_DIR%\Scripts\wrappers\conda"

@echo Removing wrappers from %WRAPPERS_DIR% > %ENV_DIR%\.messages.txt
@rmdir /s /q %WRAPPERS_DIR%
