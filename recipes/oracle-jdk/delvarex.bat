SETLOCAL ENABLEDELAYEDEXPANSION

@SET VAR=
@CD\
@CLS
:Loop
@ECHO.
@ECHO This is the exact FOR loop we're going to run:
@TYPE "%~f0" | FindStr "(" | FindStr /V "FINDSTR"
@ECHO Note that the FOR command on the prompt does NOT change with each iteration:
SET VAR
FOR %%A IN (1 2 3) DO SET VAR=!VAR!%%A
SET VAR
@ECHO.
@PAUSE
@GOTO Loop

ENDLOCAL