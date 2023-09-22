"%R%" --slave -e "install.packages('fastglm', repos = 'https://cloud.r-project.org')"
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1

