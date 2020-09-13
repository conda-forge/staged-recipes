cd CPP\7zip
nmake PLATFORM=x64 NEW_COMPILER=1 MY_DYNAMIC_LINK=1

copy Bundles\Alone7z\x64\7zr.exe %LIBRARY_PREFIX%\bin\7zr.exe
copy Bundles\Alone\x64\7za.exe %LIBRARY_PREFIX%\bin\7za.exe
copy UI\Console\x64\7z.exe %LIBRARY_PREFIX%\bin\7z.exe
