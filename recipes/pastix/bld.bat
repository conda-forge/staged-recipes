cmake -G "Ninja" -B build -S . ^
      -D CMAKE_BUILD_TYPE="Release" ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
      -D PASTIX_ORDERING_SCOTCH:BOOL=OFF

ninja install