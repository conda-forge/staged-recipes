cargo-bundle-licenses --format yaml --output "%SRC_DIR%\THIRDPARTY.yml"

mkdir "%PREFIX%\Menu"
powershell -Command "(Get-Content '%RECIPE_DIR%\menu.json') -replace '__PKG_VERSION__', '%PKG_VERSION%' -replace '__PKG_MAJOR_VER__', '%PKG_VERSION:~0,1%' | Set-Content '%PREFIX%\Menu\%PKG_NAME%_menu.json'"
copy "%RECIPE_DIR%\alacritty.icns" "%PREFIX%\Menu\alacritty.icns"

cargo install --locked --path .\alacritty --root %PREFIX%
rmdir /s /q target
