
cmake -G "NMake Makefiles" ^
      %CMAKE_ARGS% ^
      -D CMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_LIBDIR=lib ^
      %SRC_DIR%
cmake --build .
cmake --build . --target install -D CMAKE_INSTALL_PREFIX=%PREFIX%

