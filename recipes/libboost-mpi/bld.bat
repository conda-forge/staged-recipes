:: Start with bootstrap
call bootstrap.bat
if errorlevel 1 exit 1

:: Add "using mpi ;" to project config
echo &echo.      >> %SRC_DIR%\project-config.jam
echo import os ; >> %SRC_DIR%\project-config.jam
echo local LIBRARY_INC = [ os.environ LIBRARY_INC ] ; >> %SRC_DIR%\project-config.jam
echo local LIBRARY_LIB = [ os.environ LIBRARY_LIB ] ; >> %SRC_DIR%\project-config.jam
echo using mpi : : >> %SRC_DIR%\project-config.jam
echo   ^<include^>$(LIBRARY_INC) >> %SRC_DIR%\project-config.jam
echo   ^<library-path^>$(LIBRARY_LIB) >> %SRC_DIR%\project-config.jam
echo   ^<find-shared-library^>msmpi >> %SRC_DIR%\project-config.jam
echo ; >> %SRC_DIR%\project-config.jam

:: Build step
.\b2 install ^
    --build-dir=buildboost ^
    --prefix=%LIBRARY_PREFIX% ^
    toolset=msvc-%VS_MAJOR%.0 ^
    address-model=%ARCH% ^
    variant=release ^
    threading=multi ^
    link=shared ^
    install-dependencies=off ^
    -j%CPU_COUNT% ^
    --layout=system ^
    --with-mpi
if errorlevel 1 exit 1

:: Remove all headers as we only build Boost.MPI libraries.
rmdir /s /q %LIBRARY_INC%\boost

:: Remove all CMake config as we only build Boost.MPI libraries.
rmdir /s /q %LIBRARY_LIB%\cmake

:: Move dll's to LIBRARY_BIN
move %LIBRARY_LIB%\boost*.dll "%LIBRARY_BIN%"
if errorlevel 1 exit 1
