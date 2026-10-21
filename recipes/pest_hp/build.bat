@echo on

REM SpeedTest is a unused function that causes a compilation error.
REM Don't use 'sed -i' since it is not portable across all platforms. Create
REM a temporary file and then move it to the original file instead.
sed '/SpeedTest/d' ip.c > ip.c.tmp
move ip.c.tmp ip.c

REM CFLAGS needs to include -DWIN32 to select the correct header files for
REM Windows.  The default CFLAGS in the *.mak makefiles does not include this.
for %%f in (.\*.mak) do (
    sed 's/CFLAGS=/CFLAGS=-DWIN32 /g' %%f > %%f.tmp
    move %%f.tmp %%f
)

make -f pest_hp.mak cppp
make -f pest_hp.mak clean
make -f pest_hp.mak pest_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pwhisp_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pcost_hp
make -f pest_hp.mak clean
make -f cmaes_hp.mak cmaes_hp
make -f pest_hp.mak clean
make -f jactest_hp.mak jactest_hp
make -f pest_hp.mak clean
make -f rsi_hp.mak rsi_hp
make -f pest_hp.mak clean
make -f ensi_hp.mak ensiprep
make -f ensi_hp.mak ensimod
make -f ensi_hp.mak postensiunc
make -f pest_hp.mak clean
make -f agent_hp.mak agent_hp
make -f pest_hp.mak clean

mkdir %PREFIX%\bin

REM cppp.exe is only used to build the executables.  Shouldn't install it.
del cppp.exe

xcopy ".\\*.exe" "%PREFIX%\bin" /Y /I
