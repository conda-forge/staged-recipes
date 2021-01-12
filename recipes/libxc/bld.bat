
cmake -G"Ninja" ^
      -H%SRC_DIR% ^
      -Bbuild ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
      -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
      -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
      -DCMAKE_C_FLAGS="/wd4101 /wd4996 %CFLAGS%" ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      -DENABLE_XHOST=OFF ^
      -DBUILD_TESTING=OFF
if errorlevel 1 exit 1

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

ctest --output-on-failure
if errorlevel 1 exit 1
:: tests outside build phase

