sed -i 's/gnu/msvc/' changeforest-r/src/Makevars.win
"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1