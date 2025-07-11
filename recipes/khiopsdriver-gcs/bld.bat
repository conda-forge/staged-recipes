@echo on

cmake -LAH -G "Ninja" ^
    %CMAKE_ARGS% ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_MESSAGE_LOG_LEVEL=STATUS ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -B build .
if errorlevel 1 exit 1

cmake --build build --target install --config Release
if errorlevel 1 exit 1

xcopy /y /s %LIBRARY_PREFIX%\bin\*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1