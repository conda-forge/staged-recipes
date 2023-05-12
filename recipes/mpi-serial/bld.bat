set "cwd=%cd%"

set "LIBRARY_PREFIX=%LIBRARY_PREFIX:\=/%"

bash -lc "echo 'none /tmp usertemp binary,posix=0 0 0' >>/etc/fstab"
bash -lc "mount"
rem bash -lc "autoreconf -fvi"
bash -lc "./configure"

mingw32-make
mingw32-make install
