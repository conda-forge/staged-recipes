"%R%" --slave -e "install.packages('fastglm', repos = 'https://cloud.r-project.org')"
echo CXX_STD=CXX17>>src\Makevars.win
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1

