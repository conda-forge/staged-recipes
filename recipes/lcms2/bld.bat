cd %SRC_DIR%
md build
cd build

cp "%RECIPE_DIR%/CMakeLists.txt" "%SRC_DIR%/CMakeLists.txt"

cmake -G "NMake Makefiles"                     ^
      -DCMAKE_BUILD_TYPE=Release               ^
      -DCMAKE_VERBOSE_MAKEFILE=ON              ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX%  ^
      -DJPEG_LIBRARY=%LIBRARY_LIB%\libjpeg.lib ^
      -DJPEG_INCLUDE_DIR=%LIBRARY_INC%         ^
      -DTIFF_LIBRARY=%LIBRARY_LIB%\libtiff.lib ^
      -DTIFF_INCLUDE_DIR=%LIBRARY_INC%         ^
      -DZLIB_LIBRARY=%LIBRARY_LIB%\zlib.lib    ^
      -DZLIB_INCLUDE_DIR=%LIBRARY_INC%         ^
      -DCMAKE_EXE_LINKER_FLAGS="/verbose:lib"  ^
      ..
if errorlevel 1 exit 1

cmake --build . --target INSTALL --config Release
if errorlevel 1 exit 1

