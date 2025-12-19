set PKG_LIBS=-lpthread

:: Create a wrapper for the shell (used by configure/make)
echo #!/bin/sh > gcc
echo exec %CC% "$@" >> gcc

:: Create a wrapper for CMD (just in case)
echo @%CC% %%* > gcc.bat

:: Add gcc shims to .Rbuildignore
echo ^gcc$      >> .Rbuildignore
echo ^gcc\.bat$ >> .Rbuildignore

:: Add current directory to PATH so these are found
set "PATH=%CD%;%PATH%"

:: Now run the install
"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
