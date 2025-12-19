set PKG_LIBS=-lpthread
echo @%CC% %%* > gcc.bat
set "PATH=%CD%;%PATH%"
"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
