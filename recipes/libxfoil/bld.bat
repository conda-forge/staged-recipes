mkdir build
cd build 

cmake -G "MinGW Makefiles" ^
      -D CMAKE_BUILD_TYPE:STRING=Release ^
      -D CMAKE_PREFIX_PATH:FILEPATH=%LIBRARY_PREFIX% ^
      -D CMAKE_INSTALL_PREFIX:FILEPATH=%LIBRARY_PREFIX% ^
      -D CMAKE_SH="CMAKE_SH-NOTFOUND" ^
      ..

mingw32-make
mingw32-make install

rem create the libxfoil.lib which is needed for linking!!
rem copied from lapack-feedstock
dumpbin /exports "%LIBRARY_PREFIX%/lib/libxfoil.dll" > exportsxfoil.txt
echo LIBRARY libxfoil.dll > xfoil.def
echo EXPORTS >> xfoil.def
for /f "skip=19 tokens=4" %%A in (exportsxfoil.txt) do echo %%A >> xfoil.def
lib /def:xfoil.def /out:xfoil.lib /machine:x64
copy xfoil.lib "%LIBRARY_PREFIX%/lib/xfoil.lib"

cd ..

%PYTHON% setup.py build_ext
%PYTHON% setup.py install
