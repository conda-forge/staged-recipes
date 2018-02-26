mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX="%PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DOPTION_BUILD_SHARED_LIBS=yes ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
nmake
if errorlevel 1 exit 1

:: Test.
ctest
if errorlevel 1 exit 1

:: Install.
nmake install
if errorlevel 1 exit 1
