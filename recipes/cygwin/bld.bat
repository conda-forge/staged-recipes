REM this bat file adapted from: https://gist.github.com/wjrogers/1016065
REM -- Automates cygwin installation

SETLOCAL

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=make,automake,autoconf,readline,libncursesw-devel
set HASH_TYPE=SHA256
set HASH=dd0754a9b238954b7cca407a4e4146de4a8281d1825bc2328d992e0d8d8005fe
set FILENAME=setup.exe

curl -L https://cygwin.com/setup-x86_64.exe -o %FILENAME%
set command="if ( $($(CertUtil -hashfile %FILENAME% %HASH_TYPE%)[1] -replace ' ','') -eq '%HASH%' ) { echo 'setup download ok' } else {echo 'setup checksum bad.  Has it changed/been updated?' -and exit 1}"
powershell -Command %command%
if errorlevel 1 exit 1

REM -- Configure our paths
SET SITE=http://mirrors.kernel.org/sourceware/cygwin/
SET LOCALDIR=%LIBRARY_PREFIX%/cygwin
SET ROOTDIR=%LIBRARY_PREFIX%

REM -- Do it!
ECHO *** INSTALLING PACKAGES
%FILENAME% -B -q -D -L -d -g -o -s %SITE% -l "%LOCALDIR%" -R "%ROOTDIR%" -C Base -P %PACKAGES%

ENDLOCAL

EXIT /B 0
