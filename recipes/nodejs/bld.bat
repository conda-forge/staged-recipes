if "%ARCH%"=="32" (
   set PLATFORM=x86
) else (
  set PLATFORM=x64
)

call vcbuild.bat nosign release %PLATFORM%

COPY Release\node.exe %LIBRARY_BIN%\node.exe

%LIBRARY_BIN%\node.exe deps\npm\cli.js install npm -gf
