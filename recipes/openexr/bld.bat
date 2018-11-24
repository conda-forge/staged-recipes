mkdir build
cd build

REM -DOPENEXR_BUILD_ILMBASE:BOOL=OFF ^
REM -DILMBASE_INCLUDE_DIR:PATH=%_LIBRARY_PREFIX%/include ^

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DOPENEXR_NAMESPACE_VERSIONING:BOOL=OFF ^
      -DOPENEXR_BUILD_SHARED:BOOL=ON ^
      -DOPENEXR_BUILD_PYTHON_LIBS:BOOL=OFF ^
      ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
