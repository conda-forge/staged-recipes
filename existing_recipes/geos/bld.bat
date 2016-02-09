mkdir build
cd build

set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

cmake .. -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release

nmake install || exit 1

copy ..\include\geos.h %LIBRARY_INC%\geos.h || exit 1
copy lib\*.exp %LIBRARY_LIB%\ || exit 1
copy lib\*.lib %LIBRARY_LIB%\ || exit 1
