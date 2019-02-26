%BUILD_PREFIX%\Scripts\scons.bat ^
	PREFIX=%PREFIX% ^
	APR=%PREFIX% ^
	APU=%PREFIX% ^
	GSSAPI=%PREFIX% ^
	OPENSSL=%PREFIX% ^
	ZLIB=%PREFIX% ^
if errorlevel 1 exit 1

%BUILD_PREFIX%\Scripts\scons.bat install
if errorlevel 1 exit 1
