setlocal EnableDelayedExpansion

:: Configure using the CMakeFiles
cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DBUILD_SHARED_LIBS=ON ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -S . -B build
if errorlevel 1 exit 1

:: Build!
cmake --build build
if errorlevel 1 exit 1

:: Install!
cmake --install build
if errorlevel 1 exit 1
