mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
      -DCMAKE_INCLUDE_PATH="%INCLUDE_INC%" ^
      -DBUILD_SHARED_LIBS=OFF ^
      -DWITH_FGT=%LIBRARY_PREFIX% ^
      -DWITH_JSONCPP=OFF ^
      -DWITH_STRICT_WARNINGS=ON ^
      %SRC_DIR%
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1

