setlocal EnableDelayedExpansion
@echo on

cd forgebuild
if errorlevel 1 exit 1

:: call install script directly because executing the install target re-builds
:: (in that case, the re-build happens because timestamps have changed)
cmake -P cmake_install.cmake
if errorlevel 1 exit 1

if NOT [%PKG_NAME%] == [limesuite] (
    if NOT [%PKG_NAME%] == [soapysdr-module-lms7] (
        :: remove Soapy SDR components
        for /d %%i in ("%LIBRARY_PREFIX%\lib\SoapySDR\modules*") do rd /s /q "%%~i"
        if errorlevel 1 exit 1
    )

    :: remove GUI components
    del %LIBRARY_PREFIX%\bin\LimeSuiteGUI.exe
    if errorlevel 1 exit 1
)
