@echo on

:: Link conda-forge's libghostty-vt and generate the bindings from its headers
:: instead of building the vendored Ghostty submodule with Zig.
set "GHOSTTY_VT_LIB_DIR=%LIBRARY_LIB%"
set "GHOSTTY_VT_INCLUDE_DIR=%LIBRARY_INC%"

:: bindgen loads libclang.dll at runtime; conda-forge only ships a versioned DLL.
set "LIBCLANG_PATH=%BUILD_PREFIX%\Library\bin"
for %%f in ("%BUILD_PREFIX%\Library\bin\libclang-*.dll") do copy /y "%%f" "%BUILD_PREFIX%\Library\bin\libclang.dll"
if not exist "%BUILD_PREFIX%\Library\bin\libclang.dll" exit 1

:: Use conda-forge's zstd instead of the copy bundled with zstd-sys.
set ZSTD_SYS_USE_PKG_CONFIG=1

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

:: HERDR_APP_RELEASE stays unset: no self-updates and no telemetry endpoint.
cargo auditable install --locked --no-track --bin herdr-app --root "%LIBRARY_PREFIX%" --path .
if errorlevel 1 exit 1
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if errorlevel 1 exit 1

if not exist "%PREFIX%\Menu" mkdir "%PREFIX%\Menu"
copy "%RECIPE_DIR%\Menu\herdr-app.json" "%PREFIX%\Menu\herdr-app.json"
if errorlevel 1 exit 1
copy assets\icons\herdr-app.ico "%PREFIX%\Menu\herdr-app.ico"
if errorlevel 1 exit 1
