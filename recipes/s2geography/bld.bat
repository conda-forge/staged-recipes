mkdir build_cpp
cd build_cpp

cmake %SRC_DIR% -G "NMake Makefiles" ^
                -DCMAKE_CXX_STANDARD=17 ^
                -DCMAKE_PREFIX_PATH="%PREFIX%" ^
                -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
                -DCMAKE_BUILD_TYPE=Release ^
                -DS2GEOGRAPHY_S2_SOURCE=CONDA ^
                -DBUILD_SHARED_LIBS=ON ^
                -DS2GEOGRAPHY_BUILD_EXAMPLES=OFF ^
                -DS2GEOGRAPHY_BUILD_TESTS=OFF ^
                -DS2GEOGRAPHY_CODE_COVERAGE=OFF ^
                -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=TRUE
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
