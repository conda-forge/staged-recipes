


nmake /f Makefile.nt
if errorlevel 1 exit 1

copy cgi-fcgi\Release\cgi-fcgi.exe %PREFIX%\bin
copy libfcgi\Release\libfcgi.dll %PREFIX%\bin

(robocopy include %PREFIX%\include "*.h") ^& IF %ERRORLEVEL% LEQ 1 exit 0

