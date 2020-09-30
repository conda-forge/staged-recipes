if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release

for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.exe) do @copy "%%f" %LIBRARY_BIN%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.dll) do @copy "%%f" %LIBRARY_BIN%
for /r %SRC_DIR%\out\Release-%PLATFORM% %%f in (*.lib) do @copy "%%f" %LIBRARY_LIB%

copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.f90 %LIBRARY_INC%\mpi.f90
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.h %LIBRARY_INC%\mpi.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpif.h %LIBRARY_INC%\mpif.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpio.h %LIBRARY_INC%\mpio.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpiwarning.h %LIBRARY_INC%\mpiwarning.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mspms.h %LIBRARY_INC%\mspms.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\pmidbg.h %LIBRARY_INC%\pmidbg.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x64\mpifptr.h %LIBRARY_INC%\mpifptr.h


dir /s /b


