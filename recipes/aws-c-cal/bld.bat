mkdir "%SRC_DIR%"\build
pushd "%SRC_DIR%"\build

cmake -G "Ninja" ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBUILD_SHARED_LIBS=ON ^
      ..
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
