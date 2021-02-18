set TORCH_INSTALL=1
"%R%" -e "options(repos=c(CRAN='https://cloud.r-project.org')); source('tools/buildlantern.R')"
"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
