
mkdir build
cd build

cmake -G "NMake Makefiles" ^
      %CMAKE_ARGS% ^
      -DCMAKE_INSTALL_PREFIX=$PREFIX ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DPODOFO_BUILD_SHARED=1 ^
      -DPODOFO_HAVE_JPEG_LIB=1 ^
      -DPODOFO_HAVE_PNG_LIB=1 ^
      -DPODOFO_HAVE_TIFF_LIB=1
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INCLUDE_PATH=%LIBRARY_INC% ^
      -D CMAKE_LIBRARY_PATH=%LIBRARY_LIB% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install 
if errorlevel 1 exit 1
