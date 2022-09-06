cmake -Bbuild ^
  -G "NMake Makefiles" ^
  -D BUILD_UVW_SHARED_LIB=ON ^
  -D BUILD_TESTING=OFF ^
  -D CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE ^
  -D CMAKE_BUILD_TYPE=Release ^
  -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  .

cmake --build build --target install
