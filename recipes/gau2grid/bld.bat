:: %BUILD_PREFIX%/bin/cmake ^
cmake -G Ninja ^
        -H%SRC_DIR% ^
        -Bbuild ^
        -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
        -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
        -DCMAKE_BUILD_TYPE=Release ^
        -DCMAKE_INSTALL_LIBDIR=lib ^
        -DPYMOD_INSTALL_LIBDIR="/python%PY_VER%/site-packages" ^
        -DINSTALL_PYMOD=ON ^
        -DBUILD_SHARED_LIBS=ON ^
        -DENABLE_GENERIC=ON ^
        -DPYTHON_EXECUTABLE=%PYTHON% ^
        -DMAX_AM=8
if errorlevel 1 exit 1
        ::-DCMAKE_C_FLAGS="%CFLAGS%" ^
        ::-DCMAKE_C_COMPILER=clang-cl ^
        ::-DCARTESIAN_ORDER=row ^
        ::-DSPHERICAL_ORDER=gaussian ^

cd build
cmake --build . ^
      --config Release
      ::--config Release ^
      ::-- -j %CPU_COUNT%
if errorlevel 1 exit 1

cmake --build . ^
      --config Release ^
      --target install
      ::--target install ^
      ::-- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase
