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
      -DINSTALL_PYMOD=OFF ^
      -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996" ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON ^
      -DBUILD_SHARED_LIBS=ON ^
      -DENABLE_GENERIC=ON ^
      -DPYTHON_EXECUTABLE=%BUILD_PREFIX%/python.exe ^
      -DMAX_AM=8
if errorlevel 1 exit 1

cd build
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: tests outside build phase

:: When pygau2grid returns
::      -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
::      -DPYTHON_EXECUTABLE=%PYTHON% ^
 
:: Perils
:: %BUILD_PREFIX%/bin/cmake ^  # deadly on c-f
:: -DCMAKE_C_FLAGS="/wd4018 /wd4101 /wd4996 %CFLAGS%" ^  # error MSB3073
::cmake -G "%CMAKE_GENERATOR%" ^  # appveyor only

