
if defined ProgramFiles(x86) (
  set ARCH=x64
) else (
  set ARCH=Win32
)

devenv.exe FreeImage.2008.sln /Upgrade
msbuild FreeImage.2008.sln /property:Configuration=Release /property:Platform=%ARCH%

copy Dist\FreeImage.dll %LIBRARY_BIN%\FreeImage-3.17.0.dll
copy Dist\FreeImage.dll %LIBRARY_BIN%\FreeImage.dll
copy Dist\FreeImage.h %LIBRARY_INC%\FreeImage.h
copy Dist\FreeImage.lib %LIBRARY_LIB%\FreeImage.lib
