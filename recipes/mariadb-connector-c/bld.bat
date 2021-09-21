mkdir build && cd build

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake -GNinja ^
      -DCMAKE_BUILD_TYPE="Release" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_CXX_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DINSTALL_DOCREADMEDIR_STANDALONE="%cd%/junk" ^
      -DINSTALL_DOCDIR="%cd%/junk" ^
      ..
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1
