cmake -G "%CMAKE_GENERATOR%" ^
      -H%SRC_DIR% ^
      -Bbuild ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
    -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
    -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
    -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
    -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
    -DINSTALL_PYMOD=ON ^
    -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996" ^
    -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=true ^
    -DBUILD_SHARED_LIBS=ON ^
    -DENABLE_GENERIC=ON ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DMAX_AM=8
if errorlevel 1 exit 1

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase




::        ::-DCMAKE_C_FLAGS="%CFLAGS%" ^
::        ::-DCMAKE_C_COMPILER=clang-cl ^

::%BUILD_PREFIX%/bin/cmake ^
