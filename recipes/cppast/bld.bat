setlocal EnableDelayedExpansion

mkdir build
cd build

cmake -G "NMake Makefiles" ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_LIBRARY_PATH:PATH="%LIBRARY_PREFIX%;%LIBRARY_PREFIX%/bin" ^
      -DBUILD_SHARED_LIBS:BOOL=ON ^
      -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS:BOOL=ON ^
      ..

if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1
