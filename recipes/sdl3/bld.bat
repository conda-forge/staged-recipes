setlocal EnableDelayedExpansion

:: Configure using the CMakeFiles!
cmake -S . -B build -G Ninja ^
	  -DCMAKE_BUILD_TYPE:STRING=Release ^
	  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
	  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
	  !ADDITIONAL_OPTIONS!
if errorlevel 1 exit 1

:: Build!
cmake --build build --config Release
if errorlevel 1 exit 1

:: Install!
cmake --install build --config Release --prefix "%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
