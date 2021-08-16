@echo -------------------  bld.bat stdout start  ---------------------
rem The source code for Icon v9.5.2 does not support builds in Microsoft
rem   Visual Studio; thus, it was built with Cygwin and is installed
rem   by copying the built files to the Library\usr\bin directory.
robocopy /e %SRC_DIR% %LIBRARY_PREFIX%\usr\bin > robocopy.log 2>&1
@if %ERRORLEVEL% leq 7 (echo RoboCopy successful) else type robocopy log
@echo -------------------  bld.bat stdout end    ---------------------
@if %ERRORLEVEL% leq 7 (
  echo.    Note well that conda-verify will report that .exe and .bat or
  echo.     .cmd files having the same filename coexist in the same 
  echo.     directory.  This is intentional.
  exit /b 0
)
@echo RoboCopy failed with exit code %ERRORLEVEL%
exit /b %ERRORLEVEL%
