msbuild UnRAR.vcxproj /p:configuration=release
if errorlevel 1 exit 1

msbuild UnRARDll.vcxproj /p:configuration=release
if errorlevel 1 exit 1

mkdir %LIBRARY_INC%\unrar
if errorlevel 1 exit 1

cp UnRAR\*.hpp %LIBRARY_INC%\unrar
if errorlevel 1 exit 1

REM TODO: Install the DLLs
