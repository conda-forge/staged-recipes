if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.exe /s /e
robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.dll /s /e

copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.f90 %LIBRARY_INC%\mpi.f90
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.h %LIBRARY_INC%\mpi.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpif.h %LIBRARY_INC%\mpif.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpio.h %LIBRARY_INC%\mpio.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpiwarning.h %LIBRARY_INC%\mpiwarning.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mspms.h %LIBRARY_INC%\mspms.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\pmidbg.h %LIBRARY_INC%\pmidbg.h
copy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x64\mpifptr.h %LIBRARY_INC%\mpifptr.h

copy %SRC_DIR%\out\Release-x64\bin\sdk\lib\msmpi.lib %LIBRARY_LIB%\msmpi.lib
copy %SRC_DIR%\out\Release-x64\bin\sdk\lib\msmpifec.lib %LIBRARY_LIB%\msmpifec.lib
copy %SRC_DIR%\out\Release-x64\bin\sdk\lib\msmpifes.lib %LIBRARY_LIB%\msmpifes.lib
copy %SRC_DIR%\out\Release-x64\bin\sdk\lib\msmpifmc.lib %LIBRARY_LIB%\msmpifmc.lib
copy %SRC_DIR%\out\Release-x64\bin\sdk\lib\msmpifms.lib %LIBRARY_LIB%\msmpifms.lib

dir /s /b


