cmake %CMAKE_ARGS% -G Ninja -S "%SRC_DIR%" -B build -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" -DBUILD_EXAMPLES="OFF" -DBUILD_TESTS="OFF" 
if errorlevel 1 exit 1

ninja -C build install
if errorlevel 1 exit 1

