@echo on

cmake %CMAKE_ARGS% -GNinja %SRC_DIR%
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
