set "XCFLAGS=/W3 /MT /nologo"

set "CFLAGS=%CFLAGS% -O3 -I%LIBRARY_INC"
set "LDFLAGS=%LDFLAGS% -L%LIBRARY_LIB"
nmake /E
nmake test

copy pigz %LIBRARY_BIN%
copy unpigz %LIBRARY_BIN%
