if "%ARCH%"=="32" (
    set PLATFORM=Win32
) else (
    set PLATFORM=x64
)

msbuild.exe /p:Platform=%PLATFORM% /p:Configuration=Release

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.exe /s /e
robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_BIN%\ *.dll /s /e

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_INC%\ *.h /s /e
robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_INC%\ *.f* /s /e

robocopy %SRC_DIR%\out\Release-%PLATFORM%\bin\ %LIBRARY_LIB%\ *.lib /s /e

dir /s /b
