if "%ARCH%"=="32" (
   set ARCH=Win32
   set COPYSUFFIX=
) else (
  set ARCH=x64
  set COPYSUFFIX=64
)

msbuild source\allinone\allinone.sln /p:Configuration=Release;Platform=%ARCH%

ROBOCOPY bin%COPYSUFFIX% %LIBRARY_BIN% *.dll /E
ROBOCOPY lib%COPYSUFFIX% %LIBRARY_LIB% *.lib /E
ROBOCOPY include %LIBRARY_inc% * /E

if %ERRORLEVEL% LSS 8 exit 0
