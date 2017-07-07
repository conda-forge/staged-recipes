mkdir build
cd build

nmake /f Makefile.vc
nmake /f Makefile.vc test
nmake /f Makefile.vc install