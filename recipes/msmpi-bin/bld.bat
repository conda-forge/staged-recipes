start "" /WAIT MSMPISetup.exe -installroot %LIBRARY_PREFIX%

COPY C:\Windows\SysWOW64\msmpi.dll %LIBRARY_BIN%\
