copy %LIBRARY_LIB%\pthreads.lib %LIBRARY_LIB%\pthread.lib
copy %LIBRARY_LIB%\pthreads.lib %LIBRARY_LIB%\m.lib
copy %LIBRARY_BIN%\llvm-ar.exe %LIBRARY_BIN%\ar.exe
copy %LIBRARY_BIN%\llvm-as.exe %LIBRARY_BIN%\as.exe

copy "%RECIPE_DIR%\build.sh" .
set PREFIX=%PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
bash -lc "./build.sh"
if errorlevel 1 exit 1

del %LIBRARY_LIB%\pthread.lib
del %LIBRARY_LIB%\m.lib
del %LIBRARY_BIN%\ar.exe
del %LIBRARY_BIN%\as.exe
