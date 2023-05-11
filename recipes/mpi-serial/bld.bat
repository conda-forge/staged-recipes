set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

autoreconf -fvi
mingw32-make
mingw32-make install
