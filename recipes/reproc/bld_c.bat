mkdir build
cd build
del CMakeCache.txt

IF not x%PKG_NAME:static=%==x%PKG_NAME% (
    set BUILD_TYPE=-DBUILD_SHARED_LIBS=OFF
) ELSE (
    set BUILD_TYPE=-DBUILD_SHARED_LIBS=ON
)

cmake .. ^
      -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -D CMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
	  -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DREPROC_TEST=ON ^
      %BUILD_TYPE%

nmake
nmake install

IF not x%PKG_NAME:static=%==x%PKG_NAME% (
    REN %LIBRARY_PREFIX%\lib\reproc.lib reproc_static.lib
)