setlocal EnableDelayedExpansion

:: Configure using the CMakeFiles!
cmake -S . -B build ^
	  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo ^
	  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
	  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
	  -DSDL_INSTALL=ON ^
	  !ADDITIONAL_OPTIONS!
if errorlevel 1 exit 1

:: Build!
cmake --build build --config RelWithDebInfo
if errorlevel 1 exit 1

:: Install!
cmake --install build --config RelWithDebInfo --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
