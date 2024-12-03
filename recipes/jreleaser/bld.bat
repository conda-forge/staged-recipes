setlocal EnableDelayedExpansion

mkdir "%PREFIX%\bin"
mkdir "%PREFIX%\%PKG_NAME%-%PKG_VERSION%"
xcopy "%SRC_DIR%\%PKG_NAME%-%PKG_VERSION%\*" "%PREFIX%\%PKG_NAME%-%PKG_VERSION%" /s /i /y
mklink "%PREFIX%\bin\%PKG_NAME%.bat" "%PREFIX%\%PKG_NAME%-%PKG_VERSION%\bin\%PKG_NAME%.bat"
