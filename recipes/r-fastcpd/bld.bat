"%R%" --slave -e "install.packages('fastglm', repos = 'https://cloud.r-project.org')"
"%R%" CMD INSTALL --build .
if errorlevel 1 exit 1

