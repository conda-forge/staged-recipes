@echo on

mkdir build
cd build

cmake -LAH -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_MESSAGE_LOG_LEVEL=STATUS ^
    ..

if %ERRORLEVEL% neq 0 exit 1

cmake --build . --target install --config Release
if %ERRORLEVEL% neq 0 exit 1

:: unversioned exes must avoid clobbering the qt5 packages, but versioned dlls still need to be in PATH
xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
if %ERRORLEVEL% neq 0 exit 1