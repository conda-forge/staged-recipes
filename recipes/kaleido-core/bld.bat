set APP_DIR=%PREFIX%\Library\bin\KaleidoApp
set LAUNCH_SCRIPT=%PREFIX%\Library\bin\kaleido.cmd
set BIN_LOCATION=%APP_DIR%/kaleido.cmd

mkdir %APP_DIR%
xcopy * %APP_DIR% /E/H

(
echo @echo off
echo %BIN_LOCATION% %%*
)>"%LAUNCH_SCRIPT%"
