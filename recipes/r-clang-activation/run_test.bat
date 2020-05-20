R -e "usethis::create_package('compiletest')"
IF %ERRORLEVEL% NEQ 0 exit 1
md "compiletest\src"
IF %ERRORLEVEL% NEQ 0 exit 1
copy test.cpp "compiletest\src\test.cpp"
IF %ERRORLEVEL% NEQ 0 exit 1
R CMD INSTALL --build compiletest
IF %ERRORLEVEL% NEQ 0 exit 1
