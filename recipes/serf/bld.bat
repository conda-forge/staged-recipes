scons ^
	PREFIX="%PREFIX%" ^
	APR="%PREFIX%" ^
	APU="%PREFIX%" ^
	GSSAPI="%PREFIX%" ^
	OPENSSL="%PREFIX%" ^
	ZLIB="%PREFIX%" ^
	CC="%CC%" ^
	CPPFLAGS="%CPPFLAGS%" ^
	CFLAGS="%CFLAGS%" ^
	LINKFLAGS="%LDFLAGS%"
if errorlevel 1 exit 1

scons install
if errorlevel 1 exit 1
