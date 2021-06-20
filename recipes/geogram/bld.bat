configure.bat Win64-vs2017
cd build\Win64-vs2019
cmake --build . --config=Release
cmake --install . --prefix %LIBRARY_PREFIX%
