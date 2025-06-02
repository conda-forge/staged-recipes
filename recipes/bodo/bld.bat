set "SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%"
set "CONDA_PREFIX=%PREFIX%"
set "BODO_WINDOWS_BUILD_TYPE=Release"

:: Build using pip and CMake
"%PYTHON%" -m pip install --no-deps --no-build-isolation -vv ^
    --config-settings=build.verbose=true ^
    --config-settings=logging.level="DEBUG" .
