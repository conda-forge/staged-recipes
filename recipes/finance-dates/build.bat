@echo on
set "PYO3_PYTHON=%PYTHON%"

@rem Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
copy %RECIPE_DIR%\cargo-auditable-wrapper.bat %BUILD_PREFIX%\Library\bin\cargo-auditable-wrapper.bat
if %ERRORLEVEL% neq 0 exit 1
set "CARGO=cargo-auditable-wrapper.bat"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation || exit 1
