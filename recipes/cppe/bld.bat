:: configure
cmake ^
      -H"%SRC_DIR%" ^
      -Bbuild ^
      -GNinja ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_LIBDIR="Library\lib" ^
      -DPYMOD_INSTALL_LIBDIR="..\..\Lib\site-packages" ^
      -DCMAKE_CXX_FLAGS="/wd4018 /wd4101 /wd4996 /EHsc" ^
      -DCMAKE_INSTALL_INCLUDEDIR="Library\include" ^
      -DCMAKE_INSTALL_BINDIR="Library\bin" ^
      -DCMAKE_INSTALL_DATADIR="Library" ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=true ^
      -DBUILD_SHARED_LIBS=ON ^
      -DINSTALL_DEVEL_HEADERS=OFF ^
      -DENABLE_OPENMP=ON ^
      -DENABLE_XHOST=OFF ^
      -DENABLE_PYTHON_INTERFACE=ON
if errorlevel 1 exit 1

:: build
cmake --build build ^
      --config Release ^
      -- -j %CPU_COUNT% -v -d stats
if errorlevel 1 exit 1

:: install
cmake --build build ^
      --config Release ^
      --target install
if errorlevel 1 exit 1
