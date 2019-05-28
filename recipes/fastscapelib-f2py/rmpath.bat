@echo off
goto START

-------------------------------------------------------
 rmpath.bat

 remove a path element from path

 Created Tue Sep 15 21:33:54 2009

 Source: https://stackoverflow.com/a/1430570/1539918

-------------------------------------------------------

:START
SETLOCAL ENABLEDELAYEDEXPANSION

@REM require one argument (the path element to remove)
if  _%1==_ goto USAGE

@REM  ~fs = remove quotes, full path, short names
set fqElement=%~fs1

@REM convert path to a list of quote-delimited strings, separated by spaces
set fpath="%PATH:;=" "%"

@REM iterate through those path elements
for %%p in (%fpath%) do (
    @REM  ~fs = remove quotes, full path, short names
    set p2=%%~fsp
    @REM is this element NOT the one we want to remove?
    if /i NOT "!p2!"=="%fqElement%" (
        if _!tpath!==_ (set tpath=%%~p) else (set tpath=!tpath!;%%~p)
    )
)

set path=!tpath!

@call :LISTPATH

goto ALL_DONE
-------------------------------------------------------

--------------------------------------------
:LISTPATH
  echo.
  set _path="%PATH:;=" "%"
  for %%p in (%_path%) do if not "%%~p"=="" echo     %%~p
  echo.
  goto :EOF
--------------------------------------------


--------------------------------------------
:USAGE
  echo usage:   rmpath ^<arg^>
  echo     removes a path element from the path.
  goto ALL_DONE

--------------------------------------------

:ALL_DONE
ENDLOCAL & set path=%tpath%

