cmake.exe CMakeLists.txt
if errorlevel 1 exit /b 1
cmake.exe --build . --config Release
if errorlevel 1 exit /b 1
if not exist "%PREFIX%\" mkdir "%PREFIX%"
COPY bin\swashes.exe %PREFIX%\
