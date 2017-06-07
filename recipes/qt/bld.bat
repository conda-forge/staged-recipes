
echo y | configure -prefix %LIBRARY_LIB%\qt4 ^
                   -libdir %LIBRARY_LIB% ^
                   -bindir %LIBRARY_LIB%\qt4\bin ^
                   -headerdir %LIBRARY_INC%\qt4 ^
                   -datadir %LIBRARY_LIB%\qt4 ^
                   -L %LIBRARY_LIB% ^
                   -I %LIBRARY_INC% ^
                   -release ^
                   -fast ^
                   -no-qt3support ^
                   -nomake examples ^
                   -nomake demos ^
                   -nomake docs ^
                   -opensource ^
                   -openssl ^
                   -webkit ^
                   -system-libpng ^
                   -system-zlib ^
                   -system-libtiff ^
                   -system-libjpeg
if errorlevel 1 exit 1
                
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
