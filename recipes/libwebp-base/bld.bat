
:: Hack for winres.h being called winresrc.h on VS2008
if %VS_MAJOR% LEQ 9 copy %RECIPE_DIR%\winres.h .
if errorlevel 1 exit 1

:: Build!
nmake /f Makefile.vc CFG=release-dynamic RTLIBCFG=dynamic OBJDIR=output
if errorlevel 1 exit 1

:: Copy the dll's of these dependencies
copy output\release-dynamic\%ARCH%\bin\cwebp.exe %LIBRARY_PREFIX%\bin\cwebp.exe
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\bin\dwebp.exe %LIBRARY_PREFIX%\bin\dwebp.exe
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\bin\libwebp.dll %LIBRARY_PREFIX%\bin\libwebp.dll
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\bin\libwebpdecoder.dll %LIBRARY_PREFIX%\bin\libwebpdecoder.dll
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\bin\libwebpdemux.dll %LIBRARY_PREFIX%\bin\libwebpdemux.dll
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\lib\libwebp_dll.lib %LIBRARY_PREFIX%\lib\libwebp.lib
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\lib\libwebpdecoder_dll.lib %LIBRARY_PREFIX%\lib\libwebpdecoder.lib
if errorlevel 1 exit 1
copy output\release-dynamic\%ARCH%\lib\libwebpdemux_dll.lib %LIBRARY_PREFIX%\lib\libwebpdemux.lib
if errorlevel 1 exit 1

:: Copy header files
mkdir %LIBRARY_PREFIX%\include\webp\
if errorlevel 1 exit 1
copy src\webp\decode.h %LIBRARY_PREFIX%\include\webp\
if errorlevel 1 exit 1
copy src\webp\encode.h %LIBRARY_PREFIX%\include\webp\
if errorlevel 1 exit 1
copy src\webp\types.h %LIBRARY_PREFIX%\include\webp\
if errorlevel 1 exit 1
