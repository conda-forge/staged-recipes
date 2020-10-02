REM Installation following the instructions in 
REM https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html
set ACE_ROOT=%SRC_DIR%
set ACE_SOURCE_PATH=%ACE_ROOT%\ace
set WORKSPACE=%ACE_ROOT%\ace\ace
set SLN_FILE=%WORKSPACE%.sln
set SLN_CFG=Release
set SLN_PLAT=x64

echo %SRC_DIR%
echo %ACE_ROOT%
echo %PREFIX%
echo %LIBRARY_INC%
echo %SLN_PLAT%

REM Configure step
cd %ACE_ROOT%
perl %ACE_ROOT%\bin\mwc.pl -type vs2017 -features "uses_wchar=1,zlib=0,ssl=0,openssl11=0,trio=0,xt=0,fl=0,fox=0,tk=0,qt=0,rapi=0,stlport=0,rwho=0" %WORKSPACE%.mwc

REM Create config.h file
echo #include "ace/config-windows.h" > %ACE_SOURCE_PATH%\config.h

REM Build step
echo "Executing msbuild %SLN_FILE% /p:Configuration=%SLN_CFG%,Platform=%SLN_PLAT%,PlatformToolset=v141"
msbuild %SLN_FILE% /p:Configuration=%SLN_CFG%,Platform=%SLN_PLAT%,PlatformToolset=v141 /maxcpucount
if errorlevel 1 exit 1

REM Install libraries 
REM Following the same files installed in https://github.com/microsoft/vcpkg/blob/2019.09/ports/ace/portfile.cmake#L101
copy %ACE_ROOT%\lib\ACE.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\ACE_Compression.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE_Compression.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\ACE_ETCL.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE_ETCL.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\ACE_ETCL_Parser.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE_ETCL_Parser.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\ACE_Monitor_Control.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE_Monitor_Control.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\ACE_RLECompression.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\ACE_RLECompression.lib %LIBRARY_LIB%\

REM Install headers
mkdir %LIBRARY_INC%\ace
copy %ACE_ROOT%\ace\*.h %LIBRARY_INC%\ace\
copy %ACE_ROOT%\ace\*.inl %LIBRARY_INC%\ace\
copy %ACE_ROOT%\ace\*.cpp %LIBRARY_INC%\ace\
mkdir %LIBRARY_INC%\ace\Compression
copy %ACE_ROOT%\ace\Compression\*.h %LIBRARY_INC%\ace\Compression\
copy %ACE_ROOT%\ace\Compression\*.inl %LIBRARY_INC%\ace\Compression\
mkdir %LIBRARY_INC%\ace\Compression\rle
copy %ACE_ROOT%\ace\Compression\rle\*.h %LIBRARY_INC%\ace\Compression\rle\
mkdir %LIBRARY_INC%\ace\ETCL
copy %ACE_ROOT%\ace\ETCL\*.h %LIBRARY_INC%\ace\ETCL\
copy %ACE_ROOT%\ace\ETCL\*.inl %LIBRARY_INC%\ace\ETCL\
mkdir %LIBRARY_INC%\ace\Monitor_Control
copy %ACE_ROOT%\ace\Monitor_Control\*.h %LIBRARY_INC%\ace\Monitor_Control\
mkdir %LIBRARY_INC%\ace\os_include
copy %ACE_ROOT%\ace\os_include\*.h %LIBRARY_INC%\ace\os_include\
mkdir %LIBRARY_INC%\ace\os_include\arpa
copy %ACE_ROOT%\ace\os_include\arpa\*.h %LIBRARY_INC%\ace\os_include\arpa\
mkdir %LIBRARY_INC%\ace\os_include\net
copy %ACE_ROOT%\ace\os_include\net\*.h %LIBRARY_INC%\ace\os_include\net\
mkdir %LIBRARY_INC%\ace\os_include\netinet
copy %ACE_ROOT%\ace\os_include\netinet\*.h %LIBRARY_INC%\ace\os_include\netinet\
mkdir %LIBRARY_INC%\ace\os_include\sys
copy %ACE_ROOT%\ace\os_include\sys\*.h %LIBRARY_INC%\ace\os_include\sys\
