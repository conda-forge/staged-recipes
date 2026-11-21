@echo on

cmake -G Ninja -B _build -S "%RECIPE_DIR%" ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DMCAP_SOURCE_DIR="%SRC_DIR%\cpp\mcap" ^
  -DMCAP_VERSION="%PKG_VERSION%"
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1
