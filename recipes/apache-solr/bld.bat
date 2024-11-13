@echo on
setlocal enabledelayedexpansion


:: Create the destination directories
mkdir %PREFIX%\share\solr
mkdir %PREFIX%\Scripts

:: Copy all files to the Conda environment directory
xcopy * %PREFIX%\share\solr /s /e /y || exit /b

:: Create a wrapper script in %PREFIX%\Scripts that calls the original solr.cmd
(
    echo @echo off
    echo set SOLR_PATH=%%~dp0\..\share\solr
    echo set SOLR_HOME=%%SOLR_PATH%%
    echo "%%SOLR_HOME%%\bin\solr.cmd" %%*
) > %PREFIX%\Scripts\solr.cmd

:: Make the wrapper script executable if necessary
attrib +x %PREFIX%\Scripts\solr.cmd

:: Smoke test
type %PREFIX%\Scripts\solr.cmd

