msbuild UnRAR.vcxproj /p:configuration=release
if errorlevel 1 exit 1

msbuild UnRARDll.vcxproj /p:configuration=release
if errorlevel 1 exit 1

REM TODO: Install the DLLs
