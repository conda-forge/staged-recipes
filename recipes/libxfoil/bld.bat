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
for %%i in (xfoil) do (
    dumpbin /exports "%LIBRARY_PREFIX%/lib%%i.dll" > exports%%i.txt
    echo LIBRARY lib%%i.dll > %%i.def
    echo EXPORTS >> %%i.def
    for /f "skip=19 tokens=4" %%A in (exports%%i.txt) do echo %%A >> %%i.def
    lib /def:%%i.def /out:%%i.lib /machine:x64
    copy %%i.lib "%LIBRARY_PREFIX%/lib/%%i.lib"
)

cd ..

%PYTHON% setup.py build_ext
%PYTHON% setup.py install
