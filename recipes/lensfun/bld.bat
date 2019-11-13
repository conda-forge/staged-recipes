mkdir build && cd build

set CMAKE_CONFIG="Release"
set LD_LIBRARY_PATH=%LIBRARY_LIB%

cmake -G "NMake Makefiles" ^
      -DCMAKE_BUILD_TYPE="%CMAKE_CONFIG%" ^
      -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
      -DOpenSSL_ROOT="%LIBRARY_PREFIX%" ^
      -DOPENSSL_ROOT_DIR="%LIBRARY_PREFIX%" ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DBUILD_C_GLIB=OFF ^
      -DBOOST_ROOT=%LIBRARY_PREFIX% ^
      -DBoost_INCLUDE_DIRS=%LIBRARY_PREFIX%\include ^
      -DWITH_SHARED_LIB=OFF ^
      ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG%
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1
