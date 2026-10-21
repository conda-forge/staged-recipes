@echo on

REM SpeedTest is a unused function that causes a compilation error.
REM Don't use 'sed -i' since it is not portable across all platforms. Create
REM a temporary file and then move it to the original file instead.
sed '/SpeedTest/d' ip.c > ip.c.tmp
move ip.c.tmp ip.c

REM In ip.C the #ifdef allow configuration of the code for WIN32 or UNIX.
REM Adding -DWIN32 to the CFLAGS in the makefiles so that ip.cpp (created from
REM ip.C) is built for WIN32.  This is a hack, but it works for now. Changing
REM the "DEFINES=...-DUNIX..." to "DEFINES=...-DWIN32..." in the makefiles
REM would be a better solution, but the "#ifdef UNIX" blocks in the FORTRAN
REM code actually represent use of the gfortran compiler and should stay as is.
for %%f in (.\*.mak) do (
    sed 's/\t\.\/cppp \$(DEFINES) ip\.C ip\.cpp/\t.\/cppp -DWIN32 ip.C ip.cpp/g' %%f > %%f.tmp
    move %%f.tmp %%f
)

REM PEST_HP instructions to build the executables call for the "clean" target
REM to be run after after each *.mak is used.  The *.mak files should be setup
REM differently, but for now, we will just follow the instructions and clean
REM after each *.mak.  This means that each "make ... clean" will delete
REM ip.cpp, and it is not necessarily created in later *.mak files where it
REM might be needed.  So, we will build ip.cpp first (using cmaes_hp.mak) and
REM edit the *.mak files to not delete it.  This is a hack, but it works for
REM now.
for %%f in (.\*.mak) do (
    sed 's/\trm -r \*\.cpp//g' %%f > %%f.tmp
    move %%f.tmp %%f
)

REM Compile
make -f pest_hp.mak cppp
make -f pest_hp.mak clean
REM Used here to build ip.cpp, which is needed for later makefiles.
make -f cmaes_hp.mak cmaes_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pest_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pwhisp_hp
make -f pest_hp.mak clean
make -f pest_hp.mak pcost_hp
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

REM Install
REM cppp.exe is only used to build the executables.  Shouldn't install it.
del cppp.exe

mkdir %PREFIX%\bin
xcopy ".\\*.exe" "%PREFIX%\bin" /Y /I
