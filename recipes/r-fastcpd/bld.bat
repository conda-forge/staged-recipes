"%R%" --slave -e "install.packages('fastglm', repos = 'https://cloud.r-project.org')"
mkdir %userprofile%\.R
echo CXX_STD=CXX17 >> %userprofile%\.R\Makevars.win
"%R%" CMD INSTALL --build .
IF %ERRORLEVEL% NEQ 0 exit 1

