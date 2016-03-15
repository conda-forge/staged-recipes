if "%ARCH%"=="32" (
   set PLATFORM=x86
) else (
  set PLATFORM=x64
)

vcbuild.bat nosign release %PLATFORM%

COPY Release\node.exe %LIBRARY_BIN%\node.exe
