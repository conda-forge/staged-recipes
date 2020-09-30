if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.exe /s /e
robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.dll /s /e

robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.f90 %LIBRARY_INC%\msmpi\mpi.f90 /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpi.h %LIBRARY_INC%\msmpi\mpi.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpif.h %LIBRARY_INC%\msmpi\mpif.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpio.h %LIBRARY_INC%\msmpi\mpio.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mpiwarning.h %LIBRARY_INC%\msmpi\mpiwarning.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\mspms.h %LIBRARY_INC%\msmpi\mspms.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\pmidbg.h %LIBRARY_INC%\msmpi\pmidbg.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x64\mpifptr.h %LIBRARY_INC%\msmpi\x64\mpifptr.h /s /e
robocopy %SRC_DIR%\out\Release-x64\bin\sdk\inc\x86\mpifptr.h %LIBRARY_INC%\msmpi\x86\mpifptr.h /s /e

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_LIB%\ *.lib /s /e

dir /s /b


