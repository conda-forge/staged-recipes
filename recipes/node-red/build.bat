@echo off
setlocal EnableDelayedExpansion

echo.
echo ==========================================
echo Starting Node-RED conda build process...
echo ==========================================
echo.

REM Display environment information for debugging
echo Build Environment Information:
echo - SRC_DIR: %SRC_DIR%
echo - PKG_NAME: %PKG_NAME%
echo - PKG_VERSION: %PKG_VERSION%
echo - RECIPE_DIR: %RECIPE_DIR%
echo - LIBRARY_PREFIX: %LIBRARY_PREFIX%
echo.

REM Remove any conflicting build scripts from source that might interfere
echo Step 0: Cleaning up conflicting source files...
if exist "%SRC_DIR%\build_env.bat" (
    echo   - Removing conflicting build_env.bat from source
    del /Q "%SRC_DIR%\build_env.bat"
)
if exist "%SRC_DIR%\conda_build.bat" (
    echo   - Removing conflicting conda_build.bat from source
    del /Q "%SRC_DIR%\conda_build.bat"
)
echo   - Source cleanup complete
echo.

echo Step 1: Creating package archive...
npm pack --ignore-scripts
if errorlevel 1 (
    echo ERROR: Failed to create package archive
    exit /b 1
)
echo   - Package archive created successfully
echo.

echo Step 2: Installing Node-RED globally...
npm install -g --build-from-source "%SRC_DIR%\%PKG_NAME%-%PKG_VERSION%.tgz"
if errorlevel 1 (
    echo ERROR: Failed to install Node-RED globally
    exit /b 1
)
echo   - Node-RED installed successfully
echo.

echo Step 3: Verifying installation...
where node-red >nul 2>&1
if errorlevel 1 (
    echo ERROR: node-red executable not found after installation
    echo Available executables in PATH:
    where node 2>nul
    exit /b 1
)
echo   - Node-RED executable found in PATH
echo.

echo Step 4: Setting up service directory structure...
if not exist "%LIBRARY_PREFIX%\share" (
    mkdir "%LIBRARY_PREFIX%\share"
    echo   - Created share directory
)
if not exist "%LIBRARY_PREFIX%\share\%PKG_NAME%" (
    mkdir "%LIBRARY_PREFIX%\share\%PKG_NAME%"
    echo   - Created package service directory
)
echo   - Service directory structure ready
echo.

echo Step 5: Installing service configuration...
if not exist "%RECIPE_DIR%\service.yaml" (
    echo ERROR: service.yaml not found in recipe directory
    echo Recipe directory: %RECIPE_DIR%
    echo Recipe directory contents:
    dir "%RECIPE_DIR%"
    exit /b 1
)

copy "%RECIPE_DIR%\service.yaml" "%LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy service.yaml
    echo Source: %RECIPE_DIR%\service.yaml
    echo Target: %LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml
    exit /b 1
)
echo   - Service configuration copied successfully
echo.

echo Step 6: Final verification...
if not exist "%LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml" (
    echo ERROR: service.yaml not found at expected location after copy
    echo Expected location: %LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml
    echo Target directory contents:
    dir "%LIBRARY_PREFIX%\share\%PKG_NAME%"
    exit /b 1
)

echo   - Service file verified at: %LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml
echo.

echo ==========================================
echo Build completed successfully!
echo ==========================================
echo Service configuration available at:
echo   %LIBRARY_PREFIX%\share\%PKG_NAME%\service.yaml
echo.

exit /b 0
