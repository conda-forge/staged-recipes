nuget install WiX
robocopy WiX.%PKG_VERSION%\tools "%PREFIX%"\wix /S
if %ERRORLEVEL% GEQ 8 exit 1

exit 0
