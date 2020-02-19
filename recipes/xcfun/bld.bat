:: configure
cmake -G"Ninja" ^
      -H"%SRC_DIR%" ^
      -Bbuild ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_LIBDIR="%LIBRARY_LIB%" ^
      -DCMAKE_INSTALL_INCLUDEDIR="%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_BINDIR="%LIBRARY_BIN%" ^
      -DCMAKE_INSTALL_DATADIR="%LIBRARY_PREFIX%" ^
      -DPYMOD_INSTALL_LIBDIR="/../../Lib/site-packages" ^
      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996" ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=true ^
      -DXCFUN_PYTHON_INTERFACE=ON ^
      -DXCFUN_MAX_ORDER=8 ^
      -DPYTHON_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit 1

:: build
cd build
cmake --build . ^
      --config Release ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1

:: test
:: The Python interface is tested using pytest directly
ctest -E "python-interface" --output-on-failure --verbose
if errorlevel 1 exit 1

:: install
cmake --build . ^
      --config Release ^
      --target install ^
      -- -j %CPU_COUNT%
if errorlevel 1 exit 1
