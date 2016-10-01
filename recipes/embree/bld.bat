robocopy . %LIBRARY_PREFIX% /MIR
IF %ERRORLEVEL% LSS 8 goto finish

Echo Install failed & goto :eof

:finish
Echo All done, no fatal errors.