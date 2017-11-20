
:: Had to set TIFF_NAMES, PROJ4_NAMES and JPEG_NAMES to force use of shared libs
:: Note that zlib and jpeg only get linked in if tiff is linked statically, otherwise
:: they don't seem to be used (presumeably they are used via libtiff in a dll build).
cmake -G "NMake Makefiles" ^
      -D CMAKE_BUILD_TYPE=Release ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D WITH_PROJ4=ON ^
      -D WITH_ZLIB=ON ^
      -D WITH_JPEG=ON ^
      -D WITH_TIFF=ON ^
      -D TIFF_NAMES=libtiff_i ^
      -D PROJ4_NAMES=proj_i ^
      -D JPEG_NAMES=libjpeg ^
      .
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
