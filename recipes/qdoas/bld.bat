cmake ^
  -DCMAKE_INSTALL_PREFIX:PATH=%PREFIX% ^
  -DCODA_INCLUDE_DIR=%LIBRARY_INC% ^
  .
if errorlevel 1 exit 1

cmake --build . --target install --config Release
if errorlevel 1 exit 1
