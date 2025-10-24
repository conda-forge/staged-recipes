@echo off

REM Backup existing OCL_ICD_FILENAMES
set "OCL_ICD_FILENAMES_CONDA_BACKUP=%OCL_ICD_FILENAMES%"

REM System-wide Intel ICD file locations to search
REM Check common Intel GPU driver installation paths
set "INTEL_ICD_FILE="

if exist "%WINDIR%\System32\DriverStore\FileRepository\igdlh64.inf*\intel_icd64.dll" (
    for /d %%i in ("%WINDIR%\System32\DriverStore\FileRepository\igdlh64.inf*") do (
        if exist "%%i\intel_icd64.dll" (
            set "INTEL_ICD_FILE=%%i\intel_icd64.dll"
            goto :found
        )
    )
)

if exist "C:\Windows\System32\OpenCL.dll" (
    REM Try to find Intel ICD through registry or common paths
    if exist "%ProgramFiles(x86)%\Intel\OpenCL\intel_icd64.dll" (
        set "INTEL_ICD_FILE=%ProgramFiles(x86)%\Intel\OpenCL\intel_icd64.dll"
        goto :found
    )
)

if exist "%WINDIR%\System32\intelocl64.dll" (
    set "INTEL_ICD_FILE=%WINDIR%\System32\intelocl64.dll"
    goto :found
)

:found
REM If we found an Intel ICD file, add it to OCL_ICD_FILENAMES
if defined INTEL_ICD_FILE (
    if defined OCL_ICD_FILENAMES (
        set "OCL_ICD_FILENAMES=%INTEL_ICD_FILE%;%OCL_ICD_FILENAMES%"
    ) else (
        set "OCL_ICD_FILENAMES=%INTEL_ICD_FILE%"
    )
)
