cmake.exe CMakeLists.txt
cmake.exe --build . --config Release
COPY bin\Release\swashes.exe %PREFIX%\
