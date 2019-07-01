@echo on

mkdir build-cpp
if errorlevel 1 exit 1

cd build-cpp

cmake -GNinja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%CONDA_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_POSITION_INDEPENDENT_CODE=on ^
      -DURIPARSER_BUILD_DOCS=off ^
      -DURIPARSER_BUILD_TESTS=off ^
      -DURIPARSER_BUILD_TOOLS=off ^
      -DURIPARSER_BUILD_WCHAR_T=off ^
      -DBUILD_SHARED_LIBS=on ^
      ..

cmake --build . --config Release --target install

if errorlevel 1 exit 1
