@rem bld.bat (build_msvc.bat for conda)
setlocal EnableDelayedExpansion
echo on

rem This file builds and tests CCCC under Microsoft Visual C++ Toolkit 2003
rem (distributed freely by Microsoft).
rem This platform is distributed freely by Microsoft, but does not contain
rem an implementation of 'make', hence all of the build logic is contained
rem within this script.

REM use github windows ci env vars
set CL_EXE="cl.exe"
set CL_ARGS=-nologo -c -D_CRT_SECURE_NO_WARNINGS -I "%INCLUDE%" -EHsc
set LINK_EXE="link.exe"
set LINK_ARGS=-libpath:"%LIBPATH%" -subsystem:console

REM for conda install
set "BIN_DIR=%PREFIX%\\bin"

set arg1=%1

if "%arg1%"=="--version" (
   echo // This version built on %HOSTNAME% at %DATE% > cccc\cccc_ver.h
   echo #define CCCC_VERSION %2 >> cccc\cccc_ver.h
   echo #define CCCC_VERSION_STRING "%2" >> cccc\cccc_ver.h
   set arg1=--clean
)
if "%arg1%"=="--installer" (
   goto :buildInstaller
)

REM do not require clean for CI
for %%d in ( pccts\dlg pccts\antlr cccc ) do (
   if exist %%d\*.obj del %%d\*.obj
   if exist %%d\*.exe del %%d\*.exe
)
if exist pccts\bin rmdir /s /q pccts\bin
if not exist pccts\bin mkdir pccts\bin


setlocal
cd pccts\dlg

set C_SOURCES=automata.c dlg_a.c dlg_p.c err.c main.c output.c relabel.c support.c
set C_SOURCES=%C_SOURCES% ..\support\set\set.c
set CL_ARGS=%CL_ARGS% -I ..\h -I ..\support\set  -D "USER_ZZSYN" -D "PC" -D "ZZLEXBUFSIZE=65536"  /D "LONGFILENAMES" /W3 
for %%f in ( %C_SOURCES% ) do (
   %CL_EXE% %CL_ARGS% %%f
)
%LINK_EXE% %LINK_ARGS% *.obj -out:dlg.exe
if exist dlg.exe copy dlg.exe ..\bin

cd ..\..
endlocal

setlocal
cd pccts\antlr

set C_SOURCES=antlr.c bits.c build.c dumpcycles.c dumpnode.c egman.c err.c
set C_SOURCES=%C_SOURCES% fcache.c fset.c fset2.c gen.c globals.c hash.c
set C_SOURCES=%C_SOURCES% lex.c main.c misc.c mrhoist.c pred.c scan.c
set C_SOURCES=%C_SOURCES% ..\support\set\set.c
set CL_ARGS=%CL_ARGS% -I ..\h -I ..\support\set  -D "USER_ZZSYN" -D "PC" -D "ZZLEXBUFSIZE=65536"  /D "LONGFILENAMES" /W3 
for %%f in ( %C_SOURCES% ) do (
   %CL_EXE% %CL_ARGS% %%f
)
%LINK_EXE% %LINK_ARGS% *.obj -out:antlr.exe
if exist antlr.exe copy antlr.exe ..\bin

cd ..\..
endlocal

:buildCCCC
setlocal
cd cccc
if exist *.cpp del *.cpp
set AFLAGS=-CC -k 2 -gd -ge -rl 5000 -w1 -e3 
set DFLAGS=-C2 -CC 
..\pccts\bin\antlr.exe %AFLAGS% -ft Ctokens.h cccc.g
..\pccts\bin\dlg.exe %DFLAGS% -cl CLexer parser.dlg
..\pccts\bin\antlr.exe %AFLAGS% -ft Jtokens.h java.g
..\pccts\bin\dlg.exe %DFLAGS% -cl JLexer parser.dlg

set CC_SOURCES=ccccmain cccc_db cccc_ext cccc_htm
set CC_SOURCES=%CC_SOURCES% cccc_itm cccc_mem cccc_met cccc_mod
set CC_SOURCES=%CC_SOURCES% cccc_new cccc_opt cccc_prj cccc_rec
set CC_SOURCES=%CC_SOURCES% cccc_tbl cccc_tok cccc_tpl cccc_use 
set CC_SOURCES=%CC_SOURCES% cccc_utl cccc_xml
set CPP_SOURCES=cccc CLexer CParser java JLexer JParser
set A_SOURCES=..\pccts\h\AParser ..\pccts\h\DLexerBase ..\pccts\h\ATokenBuffer
set CL_ARGS=-nologo -I ..\pccts\h -D CC_INCLUDED -D JAVA_INCLUDED -D CCCC_CONF_W32VC %CL_ARGS% 
for %%f in ( %CC_SOURCES% ) do (
   if not exist %%f.obj (
      %CL_EXE% %CL_ARGS% %%f.cc
   )
)
for %%f in ( %CPP_SOURCES% ) do (
   rem Only compile .obj files from .cpp files when they don't exist.
   if not exist %%f.obj (
      %CL_EXE% %CL_ARGS% %%f.cpp
   )
)
for %%f in ( %A_SOURCES% ) do (
   rem The ANLTR source files do not change => if an .obj file exists we can preserve 
   rem it.
   if not exist %%f.obj (
      %CL_EXE% %CL_ARGS% %%f.cpp
   )
)

%LINK_EXE% %LINK_ARGS% *.obj -out:cccc.exe
if exist cccc.exe copy cccc.exe ..
cd ..
endlocal

if not exist cccc\cccc.exe (
   echo Failed to build cccc.exe
   goto :end
)

setlocal
cd test
call run_test cc    test1
call run_test cc    test2
call run_test cc    test3
call run_test test4 test4
call run_test cc    prn1
call run_test cc    prn2
call run_test cc    prn3
call run_test cc    prn4
call run_test cc    prn5
call run_test cc    prn6
call run_test c     prn7
call run_test java  prn8
call run_test cc    prn9
call run_test cc    prn10
call run_test cc    prn11
call run_test cc    prn12
call run_test java  prn13
call run_test java  prn14
call run_test java  prn15
call run_test java  prn16
cd ..
endlocal

REM install snippet for conda
REM if "%CONDA_BUILD%"=="1" generates syntax error
mkdir "%BIN_DIR%"
copy /Y cccc.exe "%BIN_DIR%"


rem The visual C++ addin can't be built using MS Visual C++ Toolkit 2003
rem because it doesn't provide MFC header files and libraries
goto :afterAddIn
setlocal
cd vcaddin
set CPP_SOURCES=CcccDevStudioAddIn CommandForm Commands DSAddIn
set CPP_SOURCES=%CPP_SOURCES% FileList StdAfx WorkspaceInfo
for %%f in ( %CPP_SOURCES% ) do (
   if not exist %%f.obj (
      %CL_EXE% %CL_ARGS% %%f.cpp
   )
)
cd ..
endlocal
:afterAddIn

:buildInstaller
setlocal
cd w32installer
set CL_CPP_ARGS=/FI ..\cccc\cccc_ver.h /EP 
%CL_EXE% %CL_CPP_ARGS% cccc.iss.nover > cccc.iss
"c:\Program Files\My Inno Setup Extensions\iscc.exe" cccc.iss
copy output\CCCC_SETUP.exe ..
goto :end


:no_vc
echo This script expects MS Visual C++ Toolkit 2003 to be in %VCTDIR%
echo Please modify the script if the location is different.
goto :end

:noPCCTS
echo There does not appear to be a valid set of PCCTS binaries in pccts\bin.
echo Please rerun the script with the argument --clean to build these binaries.
goto :end



:end





