mv %RECIPE_DIR%/Makevars.win changeforest-r/src
IF %ERRORLEVEL% NEQ 0 exit 1
"%R%" CMD INSTALL --build changeforest-r
IF %ERRORLEVEL% NEQ 0 exit 1
