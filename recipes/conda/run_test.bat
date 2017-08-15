:: Restrict scope of all environment variables
setlocal
verify >nul

:: Deactivate external conda.
call %PREFIX%\Scripts\deactivate.bat
if errorlevel 1 exit 1

:: Configure special conda directories and files.
set "CONDARC=%PREFIX%\.condarc"
set "CONDA_ENVS_DIRS=%PREFIX%\envs"
set "CONDA_PKGS_DIRS=%PREFIX%\pkgs"

:: Add stubs for special conda directories and files.
copy nul %CONDARC%
if errorlevel 1 exit 1
mkdir %CONDA_ENVS_DIRS%
if errorlevel 1 exit 1
mkdir %CONDA_PKGS_DIRS%
if errorlevel 1 exit 1

:: Activate the built conda.
call %PREFIX%\Scripts\activate.bat %PREFIX%
if errorlevel 1 exit 1

:: Run conda tests.
call %CD%\test_conda.bat
if errorlevel 1 exit 1

:: Deactivate the built conda when done.
:: Not necessary, but a good test.
call %PREFIX%\Scripts\deactivate.bat
if errorlevel 1 exit 1

endlocal
