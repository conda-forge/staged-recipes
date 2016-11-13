
:: Build!
nmake /f Makefile.vc CFG=release-static RTLIBCFG=static OBJDIR=output
if errorlevel 1 exit 1

:: Copy the dll's of these dependencies
copy output\release-static\%ARCH%\bin\cwebp.exe %LIBRARY_PREFIX%\bin\cwebp.exe
copy output\release-static\%ARCH%\bin\dwebp.exe %LIBRARY_PREFIX%\bin\dwebp.exe
copy output\release-static\%ARCH%\lib\libwebp.lib %LIBRARY_PREFIX%\lib\libwebp.lib
copy output\release-static\%ARCH%\lib\libwebp.lib %LIBRARY_PREFIX%\lib\libwebpdecoder.lib
if errorlevel 1 exit 1

:: Copy header files
mkdir %LIBRARY_PREFIX%\include\webp\
copy src\webp\decode.h %LIBRARY_PREFIX%\include\webp\
copy src\webp\encode.h %LIBRARY_PREFIX%\include\webp\
copy src\webp\types.h %LIBRARY_PREFIX%\include\webp\
if errorlevel 1 exit 1