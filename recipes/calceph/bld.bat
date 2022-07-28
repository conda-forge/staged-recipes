nmake /f Makefile.vc

nmake /f Makefile.vc install DESTDIR=%LIBRARY_PREFIX%

rm %LIBRARY_PREFIX%\libexec
