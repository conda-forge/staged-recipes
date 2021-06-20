configure.bat Win64-vs2019
cd build\Win64-vs2019
cmake --build . --config=Release
mkdir temp
cmake --install . --prefix %LIBRARY_PREFIX%
