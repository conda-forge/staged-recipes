
mkdir build
cd build

cmake -G"NMake Makefiles" ^
  -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
  -DCMAKE_BUILD_TYPE:STRING=Release ^
  -DFMT_TEST:BOOL=OFF ^
  -DFMT_DOC:BOOL=OFF ^
  -DFMT_INSTALL:BOOL=ON ^
  ..
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
