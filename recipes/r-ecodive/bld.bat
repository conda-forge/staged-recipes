set CFLAGS=%CFLAGS% -pthread
set CXXFLAGS=%CXXFLAGS% -pthread
"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
