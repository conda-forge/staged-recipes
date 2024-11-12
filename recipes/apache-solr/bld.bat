@echo off
setlocal enabledelayedexpansion
:: Create the destination directory
mkdir %PREFIX%\share\solr %PREFIX%\Scripts

:: Copy all extracted files to the Conda environment directory
xcopy * %PREFIX%\share\solr /s /e /y || exit /b

:: Create a shortcut for the main Solr executable
mklink %PREFIX%\Scripts\solr.cmd %PREFIX%\share\solr\bin\solr.cmd || exit /b
