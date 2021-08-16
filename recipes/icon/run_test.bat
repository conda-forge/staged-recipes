@setlocal& set ECHO_ON=off& echo off
set MY_DIR=%~dps0
set EXIT_CODE=0
set PROMPT="%~n0# "
set PROMPT=%PROMPT:~1,-1%
set EXPECTED_RESULT=expected_result.txt
set ACTUAL_RESULT=%MY_DIR%\test.output.actual.txt
:: comment out the next line to obtain debugging output
set DEBUG_ECHO=@if not defined DEBUG_ECHO

pushd %MY_DIR%

@echo %ECHO_ON%
@echo.-------------------------------------------------------------------------------------
@echo.Begin test
@echo.-------------------------------------------------------------------------------------
@echo.
:: @echo.    Current directory is %CD%
:: @echo.    Current path is %PATH%

:::::::::::::::::::::::::: BEGIN INLINE TEXT  ::::::::::::::::::::::::::::::
call :heredoc :EXPECTED > %EXPECTED_RESULT% & goto :EXPECTED || goto :HERE_ERROR
There are 3 args
hello
most excellent
world
MS Windows
Cygwin
ASCII
co-expressions
dynamic loading
environment variables
external values
keyboard functions
large integers
pipes
system function
Icon Version 9.5.21b, July 21, 2021
:EXPECTED
:::::::::::::::::::::::::::: END INLINE TEXT  ::::::::::::::::::::::::::::::

@echo......................................................................................
@echo..  1. Run explicit pipe test case                                                   .
@echo......................................................................................
:: Run the first test, and capture the output.
@echo on
type %LIBRARY_PREFIX%\usr\bin\examples\example_shebang.cmd | icon -u -v0 - hello "most excellent" world > %ACTUAL_RESULT%
@echo %ECHO_ON%

:: Check for 0 or announce failure
:: ref: https://ss64.com/nt/errorlevel.html
set EXIT_CODE=%ERRORLEVEL%
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The explicit pipe test case FAILED
IF %EXIT_CODE% NEQ 0 echo.

:: Compare the output to the expected, set EXIT_CODE to nonzero when fail unless already defined.
sleep 1
cmd /c diff %EXPECTED_RESULT% %ACTUAL_RESULT%
IF %EXIT_CODE% EQU 0 set EXIT_CODE=%ERRORLEVEL%

IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The explicit pipe test case FAILED
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 type %ACTUAL_RESULT%
IF %EXIT_CODE% NEQ 0 goto farewell

@echo.
@echo.The explicit pipe test case PASSED
@echo.

@echo......................................................................................
@echo..  2. Run implicit pipe test case                                                   .
@echo......................................................................................
:: Run the first test, and capture the output.
@copy /y %LIBRARY_PREFIX%\usr\bin\examples\example_shebang.cmd world.icn >NUL || ((echo Copy to file world.icn failed)&set EXIT_CODE=1&goto farewell)
@echo on
cmd /c icon -u -v0 world.icn hello "most excellent" world > %ACTUAL_RESULT%
@echo %ECHO_ON%

:: Check for 0 or announce failure
:: ref: https://ss64.com/nt/errorlevel.html
set EXIT_CODE=%ERRORLEVEL%
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The implicit pipe test case FAILED
IF %EXIT_CODE% NEQ 0 echo.

:: Compare the output to the expected, set EXIT_CODE to nonzero when fail unless already defined.
sleep 1
cmd /c diff %EXPECTED_RESULT% %ACTUAL_RESULT%
IF %EXIT_CODE% EQU 0 set EXIT_CODE=%ERRORLEVEL%

IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The implicit pipe test case FAILED
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 type %ACTUAL_RESULT%
IF %EXIT_CODE% NEQ 0 goto farewell

@echo.
@echo.The implicit pipe test case PASSED
@echo.

@echo %ECHO_ON%
@echo......................................................................................
@echo..  3. Run no-pipe test case by directly invoking .BAT file                          .
@echo......................................................................................
@copy /y %LIBRARY_PREFIX%\usr\bin\examples\example_shebang.cmd %MY_DIR%\world.icn >NUL || ((echo Copy to file world.icn failed)&set EXIT_CODE=1&goto farewell)
@echo on
icont -u -v0 world
%DEBUG_ECHO% dir
call world hello "most excellent" world > %ACTUAL_RESULT%
@echo %ECHO_ON%
IF %EXIT_CODE% EQU 0 set EXIT_CODE=%ERRORLEVEL%

IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The no-pipe test case directly invoking .BAT file FAILED
IF %EXIT_CODE% NEQ 0 echo.

:: Compare the output to the expected, set EXIT_CODE to nonzero when fail unless already defined.
sleep 1
cmd /c diff %EXPECTED_RESULT% %ACTUAL_RESULT%
IF %EXIT_CODE% EQU 0 set EXIT_CODE=%ERRORLEVEL%

IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The no-pipe test case directly invoking .BAT file FAILED
IF %EXIT_CODE% NEQ 0 echo.

IF %EXIT_CODE% NEQ 0 type %ACTUAL_RESULT%
IF %EXIT_CODE% NEQ 0 goto farewell

@echo.
@echo.The no-pipe test case directly invoking .BAT file PASSED
@echo.

@echo %ECHO_ON%
@echo......................................................................................
@echo..  4. Run no-pipe test case indirectly invoking .EXE file                           .
@echo......................................................................................
@echo on
icont -u -v0 world
@copy /y %LIBRARY_PREFIX%\usr\bin\icont.exe world.exe 2>&1 >NUL || ((echo Copy to file world.exe failed)&set EXIT_CODE=1&goto farewell)
%DEBUG_ECHO% dir
cmd /c world hello "most excellent" world > %ACTUAL_RESULT%
@echo %ECHO_ON%
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The no-pipe test case indirectly invoking via EXE .BAT file FAILED
IF %EXIT_CODE% NEQ 0 echo.

:: Compare the output to the expected, set EXIT_CODE to nonzero when fail unless already defined.
sleep 1
cmd /c diff %EXPECTED_RESULT% %ACTUAL_RESULT%
IF %EXIT_CODE% EQU 0 set EXIT_CODE=%ERRORLEVEL%

IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 echo.The no-pipe test case indirectly invoking via EXE .BAT file FAILED
IF %EXIT_CODE% NEQ 0 echo.
IF %EXIT_CODE% NEQ 0 type %ACTUAL_RESULT%
IF %EXIT_CODE% NEQ 0 goto farewell

@echo.
@echo.The no-pipe test case indirectly invoking via EXE .BAT file PASSED
@echo.

%DEBUG_ECHO% dir %MY_DIR%

:farewell

@echo.-------------------------------------------------------------------------------------
@echo.End test
@echo.-------------------------------------------------------------------------------------

if exist %EXPECTED_RESULT% del %EXPECTED_RESULT%
popd

:: In the following line, EXIT_CODE is substituted into the line before it is executed.
:: ref: https://ss64.com/nt/endlocal.html
endlocal & exit /b %EXIT_CODE%

:HERE_ERROR
echo %~nx0: Unable to write expected results file
exit /b 1

::::::::::::::::::::::::::: :heredoc subroutine ::::::::::::::::::::::::::::
:: https://github.com/ildar-shaimordanov/cmd.scripts/blob/master/heredoc.bat
:: ref: https://stackoverflow.com/a/29329912
:: ref: https://stackoverflow.com/a/15032476/3627676
::
:heredoc LABEL
@echo off
setlocal enabledelayedexpansion
if not defined CMDCALLER set "CMDCALLER=%~f0"
set go=
for /f "delims=" %%A in ( '
	findstr /n "^" "%CMDCALLER%"
' ) do (
	set "line=%%A"
	set "line=!line:*:=!"

	if defined go (
		if /i "!line!" == "!go!" goto :EOF
		echo:!line!
	) else (
		rem delims are @ ( ) > & | TAB , ; = SPACE
		for /f "tokens=1-3 delims=@()>&|	,;= " %%i in ( "!line!" ) do (
			if /i "%%i %%j %%k" == "call :heredoc %1" set "go=%%k"
			if /i "%%i %%j %%k" == "call heredoc %1" set "go=%%k"
			if defined go if not "!go:~0,1!" == ":" set "go=:!go!"
		)
	)
)
set ECHO=%ECHO_ON%
@goto :EOF
::::::::::::::::::::::::: end :heredoc subroutine ::::::::::::::::::::::::::

