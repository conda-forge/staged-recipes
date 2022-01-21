ECHO "bld.bat: Renaming rg.exe, see https://github.com/conda-forge/staged-recipes/issues/17519"
SETLOCAL ENABLEEXTENSIONS
IF ERRORLEVEL 1 ECHO "bld.bat: Unable to enable extensions: https://www.robvanderwoude.com/cmdextmsg.php"
IF DEFINED CI (
    IF %CI% NEQ "" (
        move C:\Miniconda\Library\bin\rg.exe C:\Miniconda\Library\bin\rg-desactivate.exe
    ) ELSE (
        ECHO "bld.bat: CI is defined, but empty, so we leave rg.exe as is."
    )
) ELSE (
    ECHO "bld.bat: We are not in CI, so we leave rg.exe as is."
)
ENDLOCAL
ECHO "bld.bat: Installing OpenFisca-France..."
"%PYTHON%" -m pip install . -vv
if errorlevel 1 exit 1
ECHO bld.bat: OpenFisca-France installed!
