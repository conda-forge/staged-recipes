REM TODO: Test Conda build on Windows machine and update script as necessary
REM TODO: Getting this error https://dev.azure.com/conda-forge/feedstock-builds/_build/results?buildId=1162590&view=logs&j=53c3d5f4-e7c7-5b53-4b94-211701b2ba17&t=8f042650-8479-5761-7a4a-8d021c0bb2de&l=1946
REM TODO: "conda.CondaMultiError: [Errno 2] No such file or directory: 'D:\\Miniforge\\pkgs\\csv-validator-1.3.0-h57928b3_0\\bin\\csv-validator-cmd'"
REM Note: PREFIX, SRC_DIR, LIB, and variables that start with "PKG_" are defined by main Conda build scripts

SETLOCAL

REM Define installation path
SET INSTALL_PATH=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

ECHO Installing %PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM% to %INSTALL_PATH%

REM Creating directories
MKDIR "%INSTALL_PATH%\lib"
MKDIR "%PREFIX%\bin"

ECHO Copying files from temp storage to install path...

REM Copying dependencies
IF EXIST "%SRC_DIR%\lib\*" (
    XCOPY /E /I "%SRC_DIR%\lib\*" "%INSTALL_PATH%\lib\" || (
        ECHO Failed to copy dependencies
        EXIT /B 1
    )
) ELSE (
    ECHO No dependencies found in %SRC_DIR%\lib.
    EXIT /B 1
)

REM Copying main binary
IF EXIST "%SRC_DIR%\%PKG_NAME%-cmd-%PKG_VERSION%.jar" (
    COPY "%SRC_DIR%\%PKG_NAME%-cmd-%PKG_VERSION%.jar" "%INSTALL_PATH%\" || (
        ECHO Failed to copy application JAR file
        EXIT /B 1
    )
) ELSE (
    ECHO Main binary not found in %SRC_DIR%.
    EXIT /B 1
)

REM Copying wrapper script
IF EXIST "%SRC_DIR%\csv-validator-cmd.bat" (
    COPY "%SRC_DIR%\csv-validator-cmd.bat" "%INSTALL_PATH%\" || (
        ECHO Failed to copy wrapper script csv-validator-cmd.bat
        EXIT /B 1
    )
) ELSE (
    ECHO Wrapper script not found in %SRC_DIR%.
    EXIT /B 1
)

REM Copying LICENSE file
IF EXIST "%SRC_DIR%\LICENSE" (
    COPY "%SRC_DIR%\LICENSE" "%INSTALL_PATH%\" || (
        ECHO Failed to copy LICENSE file.
        EXIT /B 1
    )
) ELSE (
    ECHO LICENSE file not found in %SRC_DIR%.
    EXIT /B 1
)

REM Copying README text
IF EXIST "%SRC_DIR%\running-csv-validator.txt" (
    COPY "%SRC_DIR%\running-csv-validator.txt" "%INSTALL_PATH%\" || (
        ECHO Failed to copy running-csv-validator.txt.
        EXIT /B 1
    )
) ELSE (
    ECHO running-csv-validator.txt not found in %SRC_DIR%.
    EXIT /B 1
)

ECHO Setting symbolic link and file permissions...

REM Create symbolic link for the wrapper script in bin directory
SET symlinkTarget=%INSTALL_PATH%\csv-validator-cmd.bat
SET symlinkPath=%PREFIX%\bin\csv-validator-cmd

REM Check if the symlink already exists and remove it if necessary
IF EXIST "%symlinkPath%" (
    DEL "%symlinkPath%"
)

REM Create the symbolic link using mklink (requires admin privileges)
CMD /C MKLINK "%symlinkPath%" "%symlinkTarget%"

ECHO csv-validator-cmd installation complete!
ECHO If you want to change the maximum memory heap allocation (1024 MB default), run "SET csvValidatorMemory=<number in MB>" before using the csv-validator-cmd command.
ECHO See running-csv-validator.txt in the package's installation path for more information.

ENDLOCAL
