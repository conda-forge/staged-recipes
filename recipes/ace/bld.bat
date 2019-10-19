REM Installation following the instructions in 
REM https://htmlpreview.github.io/?https://github.com/DOCGroup/ACE_TAO/blob/master/ACE/ACE-INSTALL.html#unix
set ACE_ROOT=%SRC_DIR%/ACE_wrappers 

cd %ACE_ROOT%

set SLN_FILE=ACE_v14.sln
set SLN_CFG=Release
set SLN_PLAT=x64

REM Build step
msbuild "%SLN_FILE%" /p:Configuration=%SLN_CFG%,Platform=%SLN_PLAT%,PlatformToolset=v140
if errorlevel 1 exit 1

REM Install libraries 
REM Following the same files installed in https://github.com/microsoft/vcpkg/blob/2019.09/ports/ace/portfile.cmake#L101
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_Compression.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_Compression.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_ETCL.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_ETCL.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_ETCL_Parser.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_ETCL_Parser.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_Monitor_Control.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_Monitor_Control.lib %LIBRARY_LIB%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_RLECompression.dll %LIBRARY_BIN%\
copy %ACE_ROOT%\lib\%SLN_PLAT%\ACE_RLECompression.lib %LIBRARY_LIB%\

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
copy %ACE_ROOT%\ace\Compression\rle\*.inl %LIBRARY_INC%\ace\Compression\rle\
mkdir %LIBRARY_INC%\ace\ETCL
copy %ACE_ROOT%\ace\ETCL\*.h %LIBRARY_INC%\ace\ETCL\
copy %ACE_ROOT%\ace\ETCL\*.inl %LIBRARY_INC%\ace\ETCL\
mkdir %LIBRARY_INC%\ace\Monitor_Control
copy %ACE_ROOT%\ace\Monitor_Control\*.h %LIBRARY_INC%\ace\Monitor_Control\
copy %ACE_ROOT%\ace\Monitor_Control\*.inl %LIBRARY_INC%\ace\Monitor_Control\
mkdir %LIBRARY_INC%\ace\os_include
copy %ACE_ROOT%\ace\os_include\*.h %LIBRARY_INC%\ace\os_include\
copy %ACE_ROOT%\ace\os_include\*.inl %LIBRARY_INC%\ace\os_include\
mkdir %LIBRARY_INC%\ace\os_include\arpa
copy %ACE_ROOT%\ace\os_include\arpa\*.h %LIBRARY_INC%\ace\os_include\arpa\
copy %ACE_ROOT%\ace\os_include\arpa\*.inl %LIBRARY_INC%\ace\os_include\arpa\
mkdir %LIBRARY_INC%\ace\os_include\net
copy %ACE_ROOT%\ace\os_include\net\*.h %LIBRARY_INC%\ace\os_include\net\
copy %ACE_ROOT%\ace\os_include\net\*.inl %LIBRARY_INC%\ace\os_include\net\
mkdir %LIBRARY_INC%\ace\os_include\netinet
copy %ACE_ROOT%\ace\os_include\netinet\*.h %LIBRARY_INC%\ace\os_include\netinet\
copy %ACE_ROOT%\ace\os_include\netinet\*.inl %LIBRARY_INC%\ace\os_include\netinet\
mkdir %LIBRARY_INC%\ace\os_include\sys
copy %ACE_ROOT%\ace\os_include\sys\*.h %LIBRARY_INC%\ace\os_include\sys\
copy %ACE_ROOT%\ace\os_include\sys\*.inl %LIBRARY_INC%\ace\os_include\sys\
