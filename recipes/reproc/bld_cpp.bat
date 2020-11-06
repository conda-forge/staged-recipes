mkdir build-cpp
cd build-cpp
del CMakeCache.txt

IF not x%PKG_NAME:static=%==x%PKG_NAME% (
    set BUILD_TYPE="-DBUILD_SHARED_LIBS=OFF"
) ELSE (
    set BUILD_TYPE="-DBUILD_SHARED_LIBS=ON"
)

cmake .. ^
	  -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      -DREPROC++=ON ^
      -DREPROC_TEST=ON ^
      %BUILD_TYPE%

nmake all
nmake test
nmake install

IF not x%PKG_NAME:static=%==x%PKG_NAME% (
    REN %LIBRARY_PREFIX%\lib\reproc++.lib reproc++_static.lib
)