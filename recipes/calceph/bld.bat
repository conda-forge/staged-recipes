nmake /f Makefile.vc

nmake /f Makefile.vc install DESTDIR=%LIBRARY_PREFIX%

rd /s /q %LIBRARY_PREFIX%\libexec
