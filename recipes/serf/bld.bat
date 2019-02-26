scons ^
	PREFIX=%PREFIX% ^
	APR=%PREFIX% ^
	APU=%PREFIX% ^
	GSSAPI=%PREFIX% ^
	OPENSSL=%PREFIX% ^
	ZLIB=%PREFIX% ^
if errorlevel 1 exit 1

scons install
if errorlevel 1 exit 1
