@echo on

tar xf *.tar

oschmod a+rwx pest_source
cd pest_source
oschmod a+rwx doc
oschmod a+rwx edpestex
oschmod a+rwx papestex
oschmod a+rwx pestex
oschmod a+rwx ppestex

REM SpeedTest is a unused function that causes a compilation error.
REM Don't use 'sed -i' since it is not portable across all platforms. Create
REM a temporary file and then move it to the original file instead.
sed '/SpeedTest/d' ip.c > ip.c.tmp
move ip.c.tmp ip.c

REM Need to add -DWIN32 to CFLAGS for Windows builds.  It is only used to
REM compile ip.c in the beopest.mak file.
REM Don't use 'sed -i' since it is not portable across all platforms. Create
REM a temporary file and then move it to the original file instead.
sed 's/CFLAGS=/CFLAGS=-DWIN32 /g' beopest.mak > beopest.mak.tmp
move beopest.mak.tmp beopest.mak

REM Compile
make cppp
make -f pest.mak all
make clean
make -f ppest.mak all
make clean
make -f pestutl1.mak all
make clean
make -f pestutl2.mak all
make clean
make -f pestutl3.mak all
make clean
make -f pestutl4.mak all
make clean
make -f pestutl5.mak all
make clean
make -f pestutl6.mak all
make clean
make -f pestutl7.mak all
make clean
make -f sensan.mak all
make clean
make -f beopest.mak all
make clean

REM Install
REM cppp.exe is only used to build the executables.  Shouldn't install it.
del cppp.exe

mkdir %PREFIX%\bin
xcopy ".\\*.exe" "%PREFIX%\bin" /Y /I
