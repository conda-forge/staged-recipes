mkdir build
cd build

REM set environement variables
set HDF5_EXT_ZLIB=zlib.lib

REM configure step
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE:STRING=RELEASE -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% -DHDF5_BUILD_CPP_LIB=ON -DBUILD_SHARED_LIBS:BOOL=ON -DHDF5_BUILD_HL_LIB=ON -DHDF5_BUILD_TOOLS:BOOL=ON -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=ON %SRC_DIR%
if errorlevel 1 exit 1

REM Build C libraries and tools
nmake
if errorlevel 1 exit 1

REM Install step
nmake install
if errorlevel 1 exit 1

REM remove msvc redist files
cd %LIBRARY_BIN%
rm msvc*.dll
rm Microsoft.VC90.CRT.manifest

REM rename exeutable files to remove *dll suffix
cd %LIBRARY_BIN%
move gif2h5dll.exe gif2h5.exe
move h52gifdll.exe h52gif.exe
move h5copydll.exe h5copy.exe
move h5debugdll.exe h5debug.exe
move h5diffdll.exe h5diff.exe
move h5dumpdll.exe h5dump.exe
move h5importdll.exe h5import.exe
move h5jamdll.exe h5jam.exe
move h5lsdll.exe h5ls.exe
move h5mkgrpdll.exe h5mkgrp.exe
move h5repackdll.exe h5repack.exe
move h5repartdll.exe h5repart.exe
move h5statdll.exe h5stat.exe
move h5unjamdll.exe h5unjam.exe
