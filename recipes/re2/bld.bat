mkdir -p build
cd build
cmake -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=%PREFIX% \
      -G "NMake Makefiles" \
      ..
if errorlevel 1 exit 1

nmake -j %CPU_COUNT%
if errorlevel 1 exit 1

nmake -j %CPU_COUNT% test
if errorlevel 1 exit 1

nmake -j %CPU_COUNT% install
if errorlevel 1 exit 1
