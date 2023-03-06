mkdir build_cpp
cd build_cpp

cmake %SRC_DIR% -G "NMake Makefiles" ^
                -DCMAKE_CXX_STANDARD=17 ^
                -DCMAKE_PREFIX_PATH="%PREFIX%" ^
                -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
                -DCMAKE_BUILD_TYPE=Release 
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1