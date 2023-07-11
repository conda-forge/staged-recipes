"%R%" CMD INSTALL --build . %R_ARGS%
"%R%" CMD INSTALL --with-libpng-prefix=/usr/X11/lib/ rgl %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
