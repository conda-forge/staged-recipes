cmake ^
  -G"Visual Studio 14 2015 Win64" ^
  -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX%
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
