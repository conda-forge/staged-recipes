mkdir _build
cd _build

:: configure
cmake ^
	"%SRC_DIR%" ^
	-G "NMake Makefiles" ^
	-DCMAKE_BUILD_TYPE:STRING=Release ^
	-DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

:: build
cmake --build . --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: test
ctest --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: install
cmake --build . --parallel "%CPU_COUNT%" --verbose --target install
if errorlevel 1 exit 1
