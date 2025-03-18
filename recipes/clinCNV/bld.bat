@echo on
setlocal EnableDelayedExpansion

:: Define installation paths
set SRC_DIR=%CD%
set BIN_DIR=%PREFIX%\bin
set CLINCNV_DIR=%BIN_DIR%\clincnv

:: Create the necessary directory
mkdir "%CLINCNV_DIR%"

:: Copy all source files to the installation directory
xcopy /E /I /Y "%SRC_DIR%\*" "%CLINCNV_DIR%\"

:: List of R script names
set scripts=clinCNV mergeFilesFromFolder mergeFilesFromFolderDT

:: Loop through each script and create a Windows batch wrapper
for %%s in (%scripts%) do (
    echo @echo off > "%BIN_DIR%\%%s.bat"
    echo Rscript "%CLINCNV_DIR%\%%s.R" %%* >> "%BIN_DIR%\%%s.bat"
)

:: Ensure scripts are executable
chmod +x "%CLINCNV_DIR%\*.R"

exit /b 0
