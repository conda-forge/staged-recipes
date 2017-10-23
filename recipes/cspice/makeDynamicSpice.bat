@echo off
rem
rem    makeDynamicSpice.bat
rem
rem    Creates the cspice.dll when run within the src/cspice directory.
rem    Requires Visual Studio development tools to be in the path.
rem    Specifically cl.exe and link.exe .
rem
rem
@echo on
rem Running makeDynamicSpice.bat, this may take some time (a minute or two) ...
@echo off

set cl= /c /O2 /nologo -D_COMPLEX_DEFINED -DMSDOS -DOMIT_BLANK_CC -DNON_ANSI_STDIO

rem
rem  The optimization algorithm has a very tough time with zzsecptr.c,
rem  so exempt this routine from optimization.
rem

rename zzsecprt.c zzsecprt.x

rem
rem  Compile everything else.
rem

for %%f in (*.c) do cl %%f >nul

rem
rem  Set the cl variable to omit optimization.  Compile zzsecprt.c.
rem

set cl= /c /nologo -D_COMPLEX_DEFINED -DMSDOS -DOMIT_BLANK_CC  >nul

rename zzsecprt.x zzsecprt.c

cl zzsecprt.c >nul

dir /b *.obj > temp.lst
@echo on
rem Finished Compiling, starting to Link spice.
@echo off
rem
rem Create cspice.dll
rem

link /DLL /OUT:cspice.dll /DEF:cspice.def /IMPLIB:cspice.lib @temp.lst >nul
@echo on
rem Finished Linking Spice, makeDynamicSpice.bat completed.
