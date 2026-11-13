@echo on

cmake -G Ninja -B _build -S "%RECIPE_DIR%" %CMAKE_ARGS% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
  -DCMAKE_INSTALL_LIBDIR=lib ^
  -DLUAU_SOURCE_DIR="%SRC_DIR%" ^
  -DLUAU_VERSION="%PKG_VERSION%" ^
  -DLUAU_BUILD_CLI=ON ^
  -DLUAU_BUILD_TESTS=OFF ^
  -DLUAU_BUILD_WEB=OFF
if errorlevel 1 exit 1
cmake --build _build --parallel %CPU_COUNT%
if errorlevel 1 exit 1
cmake --install _build
if errorlevel 1 exit 1
