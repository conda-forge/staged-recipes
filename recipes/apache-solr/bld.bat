@echo off
setlocal enabledelayedexpansion

:: Create the destination directories
mkdir %PREFIX%\share\solr
mkdir %PREFIX%\Scripts

:: Copy all extracted files to the Conda environment directory
xcopy * %PREFIX%\share\solr /s /e /y || exit /b

:: Create a wrapper script in %PREFIX%\Scripts that calls the actual solr.cmd
(
    echo @echo off
    echo set SOLR_HOME=%PREFIX%\share\solr
    echo %PREFIX%\share\solr\bin\solr.cmd %%*
) > %PREFIX%\Scripts\solr.cmd
