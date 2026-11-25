@echo on

set "CRAFT_FONTS_DIR=%SRC_DIR%\craft-fonts"
set "CRAFT_FONTS_REQUIRED=1"

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

cargo auditable install --locked --no-track --bins --root "%LIBRARY_PREFIX%" --path apps\designcraft-cli
if errorlevel 1 exit 1
