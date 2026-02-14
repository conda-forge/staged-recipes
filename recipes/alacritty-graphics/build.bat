set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"

mkdir "%PREFIX%\Menu"
powershell -Command "(Get-Content '%RECIPE_DIR%\menu.json') -replace '__PKG_VERSION__', '%PKG_VERSION%' | Set-Content '%PREFIX%\Menu\%PKG_NAME%_menu.json'"
copy "%RECIPE_DIR%\alacritty.ico" "%PREFIX%\Menu\alacritty.ico"

cargo auditable install --locked --no-track --path .\alacritty --root %LIBRARY_PREFIX%
rmdir /s /q target
