msbuild UnRAR.vcxproj /p:configuration=release
if errorlevel 1 exit 1
copy build\unrar64\release\UnRAR.exe %LIBRARY_BIN%
if errorlevel 1 exit 1

msbuild UnRARDll.vcxproj /p:configuration=release
if errorlevel 1 exit 1
copy build\unrardll64\release\UnRAR.dll %LIBRARY_BIN%
if errorlevel 1 exit 1
dir build\unrardll64\release
dir %LIBRARY_PREFIX%
dir %LIBRARY_LIB%
copy build\unrardll64\release\UnRAR.lib %LIBRARY_LIB%
if errorlevel 1 exit 1

mkdir %LIBRARY_INC%\unrar
copy UnRAR\*.hpp %LIBRARY_INC%\unrar
if errorlevel 1 exit 1
