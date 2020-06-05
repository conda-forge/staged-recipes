cmake.exe CMakeLists.txt
cmake.exe --build . --config Release
if not exist "%PREFIX%\" mkdir "%PREFIX%"
COPY bin\swashes.exe %PREFIX%\
