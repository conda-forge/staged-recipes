@echo off

cd v4-proto-py
  %PYTHON% -m pip install . \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --prefix "%PREFIX%"

type nul > "%RECIPE_DIR%\ThirdPartyLicenses.txt"
