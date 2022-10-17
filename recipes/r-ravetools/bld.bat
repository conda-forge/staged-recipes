"%R%" --no-save --no-restore -e "utils::install.packages(c('signal', 'waveslim', 'filearray'), repos=c(beauchamplab = 'https://beauchamplab.r-universe.dev', dipterix = 'https://dipterix.r-universe.dev', CRAN = 'https://cloud.r-project.org'))"
"%R%" CMD INSTALL --build . %R_ARGS%
IF %ERRORLEVEL% NEQ 0 exit /B 1
