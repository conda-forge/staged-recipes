setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

cmake -G "NMake Makefiles" ^
      %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE:STRING="Release" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DWITH_GTEST=OFF ^
      -DBUILD_SHARED_LIBS=1 ^
      -DZLIB_COMPAT=1 ^
      ..

if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

ctest -C release
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
