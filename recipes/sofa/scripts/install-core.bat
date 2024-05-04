setlocal EnableDelayedExpansion
@echo on

cd build

if [%PKG_NAME%] == [libsofa] (
    REM only the libraries (don't copy CMake metadata)
    REM XXX move to xcopy instead ?
    move temp_prefix\lib\Sofa* %LIBRARY_LIB%
    REM dll's go to LIBRARY_BIN
    move temp_prefix\bin\Sofa*.dll %LIBRARY_BIN%
    REM and plugins libraries
    cd temp_prefix\plugins
    for /D %%G in (*) do (
      mkdir %LIBRARY_PREFIX%\plugins\%%G\lib
      xcopy /y %%G\lib\*.lib %LIBRARY_PREFIX%\plugins\%%G\lib
      mkdir %LIBRARY_PREFIX%\plugins\%%G\bin
      xcopy /y %%G\bin\*.dll %LIBRARY_PREFIX%\plugins\%%G\bin
    )
    cd ..\..

    :: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
    :: This will allow them to be run on environment activation.
    for %%F in (activate deactivate) DO (
      if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
      copy %RECIPE_DIR%\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
      :: Copy unix shell activation scripts, needed by Windows Bash users
      copy %RECIPE_DIR%\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
    )
) else if [%PKG_NAME%] == [sofa-devel] (
    REM headers
    robocopy temp_prefix\include %LIBRARY_INC% /E >nul
    REM CMake metadata
    mkdir %LIBRARY_LIB%\cmake
    robocopy temp_prefix\lib\cmake %LIBRARY_LIB%\cmake /E >nul
    REM and plugins
    cd temp_prefix\plugins
    for /D %%G in (*) do (
      REM headers
      mkdir %LIBRARY_PREFIX%\plugins\%%G\include
      xcopy /e /y %%G\include %LIBRARY_PREFIX%\plugins\%%G\include
      REM CMake metadata
      mkdir %LIBRARY_PREFIX%\plugins\%%G\lib\cmake
      xcopy /e /y %%G\lib\cmake %LIBRARY_PREFIX%\plugins\%%G\lib\cmake
    )
    cd ..\..
) else (
    echo "Invalid package to install"
    exit 1
)
