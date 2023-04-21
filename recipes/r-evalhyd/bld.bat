if not exist %userprofile%/tmp mkdir %userprofile%/tmp
set TMPDIR="%userprofile%/tmp"

"%R%" CMD INSTALL --build . %R_ARGS%
if errorlevel 1 exit 1
