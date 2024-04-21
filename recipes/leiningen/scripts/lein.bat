@echo off

setLocal EnableExtensions EnableDelayedExpansion

set LEIN_VERSION=2.11.2

set ORIGINAL_PWD=%CD%
:: If ORIGINAL_PWD ends with a backslash (such as C:\),
:: we need to escape it with a second backslash.
if "%ORIGINAL_PWD:~-1%x" == "\x" set "ORIGINAL_PWD=%ORIGINAL_PWD%\"

call :FIND_DIR_CONTAINING_UPWARDS project.clj
if "%DIR_CONTAINING%" neq "" cd "%DIR_CONTAINING%"

:: LEIN_JAR and LEIN_HOME variables can be set manually.
:: Only set LEIN_JAR manually if you know what you are doing.
:: Having LEIN_JAR pointing to one version of Leiningen as well as
:: having a different version in PATH has been known to cause problems.

if "x%LEIN_HOME%" == "x" (
    set LEIN_HOME=!USERPROFILE!\.lein
)

if "x%LEIN_JAR%" == "x" set "LEIN_JAR=!CONDA_PREFIX!\lib\leiningen\libexec\leiningen-!LEIN_VERSION!-standalone.jar"

if not exist "%~dp0..\src\leiningen\version.clj" goto RUN_NO_CHECKOUT

:RUN_NO_CHECKOUT

    :: Not running from a checkout.
    if not exist "%LEIN_JAR%" goto NO_LEIN_JAR
    set CLASSPATH=%LEIN_JAR%

    if exist ".lein-classpath" (
        for /f "tokens=* delims= " %%i in (.lein-classpath) do (
            set CONTEXT_CP=%%i
        )

        if NOT "x!CONTEXT_CP!"=="x" (
            set CLASSPATH=!CONTEXT_CP!;!CLASSPATH!
        )
    )

:SETUP_JAVA

if not "x%DEBUG%" == "x" echo CLASSPATH=!CLASSPATH!
:: ##################################################

if "x!JAVA_CMD!" == "x" set JAVA_CMD=java
if "x!LEIN_JAVA_CMD!" == "x" set LEIN_JAVA_CMD=%JAVA_CMD%

rem remove quotes from around java commands
for /f "usebackq delims=" %%i in ('!JAVA_CMD!') do set JAVA_CMD=%%~i
for /f "usebackq delims=" %%i in ('!LEIN_JAVA_CMD!') do set LEIN_JAVA_CMD=%%~i

if "x%JVM_OPTS%" == "x" set JVM_OPTS=%JAVA_OPTS%
goto RUN

:NO_LEIN_JAR
echo.
echo %LEIN_JAR% can not be found.
echo The CONDA installation failed.
echo.
goto EXITRC

:: Find directory containing filename supplied in first argument
:: looking in current directory, and looking up the parent
:: chain until we find it, or run out
:: returns result in %DIR_CONTAINING%
:: empty string if we don't find it
:FIND_DIR_CONTAINING_UPWARDS
set DIR_CONTAINING=%CD%
set LAST_DIR=

:LOOK_AGAIN
if "%DIR_CONTAINING%" == "%LAST_DIR%" (
    :: didn't find it
    set DIR_CONTAINING=
    goto EOF
)

if EXIST "%DIR_CONTAINING%\%1" (
    :: found it - use result in DIR_CONTAINING
    goto EOF
)

set LAST_DIR=%DIR_CONTAINING%
call :GET_PARENT_PATH "%DIR_CONTAINING%\.."
set DIR_CONTAINING=%PARENT_PATH%
goto LOOK_AGAIN

:GET_PARENT_PATH
set PARENT_PATH=%~f1
goto EOF


:RUN
:: We need to disable delayed expansion here because the %* variable
:: may contain bangs (as in test!). There may also be special
:: characters inside the TRAMPOLINE_FILE.
setLocal DisableDelayedExpansion

set "TRAMPOLINE_FILE=%TEMP%\lein-trampoline-%RANDOM%.bat"
del "%TRAMPOLINE_FILE%" >nul 2>&1

set ERRORLEVEL=
set RC=0
"%LEIN_JAVA_CMD%" -client %LEIN_JVM_OPTS% ^
 -Dfile.encoding=UTF-8 ^
 -Dclojure.compile.path="%DIR_CONTAINING%/target/classes" ^
 -Dleiningen.original.pwd="%ORIGINAL_PWD%" ^
 -cp "%CLASSPATH%" clojure.main -m leiningen.core.main %*
SET RC=%ERRORLEVEL%
if not %RC% == 0 goto EXITRC

if not exist "%TRAMPOLINE_FILE%" goto EOF
call "%TRAMPOLINE_FILE%"
del "%TRAMPOLINE_FILE%" >nul 2>&1
goto EOF


:PROCESSPATH
rem will surround each path with double quotes before appending it to LEIN_LIBS
	for /f "tokens=1* delims=;" %%a in ("%tmpline%") do (
		set LEIN_LIBS=!LEIN_LIBS!"%%a";
		set tmpline=%%b
	)
	if not "%tmpline%" == "" goto PROCESSPATH
	goto EOF

:EXITRC
exit /B %RC%

:EOF

