@echo off

install -D -m 644 -t "%PREFIX%\share\%PKG_NAME%" ^
    "%SRC_DIR%\test\movie23_000.tif"             ^
    "%SRC_DIR%\test\movie23_000.tvips"           ^
    "%SRC_DIR%\test\movie23.idoc"
if errorlevel 1 exit /b 1
