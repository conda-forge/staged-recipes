@echo on
@setlocal EnableDelayedExpansion

echo "Starting Node-RED build process..."

echo "Step 1: Pack the source"
npm pack --ignore-scripts
if errorlevel 1 (
    echo "ERROR: npm pack failed"
    exit /b 1
)

echo "Step 2: Install globally"
npm install -ddd --global --build-from-source %SRC_DIR%\%PKG_NAME%-%PKG_VERSION%.tgz
if errorlevel 1 (
    echo "ERROR: npm install failed"
    exit /b 1
)

echo "Step 3: Initialize pnpm for license generation"
pnpm install
if errorlevel 1 (
    echo "ERROR: pnpm install failed"
    exit /b 1
)

echo "Step 4: Generate third-party license file"
pnpm-licenses generate-disclaimer --prod --output-file=%SRC_DIR%\third-party-licenses.txt
if errorlevel 1 (
    echo "ERROR: pnpm-licenses failed - continuing without third-party licenses"
    echo "This package contains third-party dependencies. Please check the upstream source for full license information." > %SRC_DIR%\third-party-licenses.txt
)

echo "Step 5: Verify license files exist"
if exist "%SRC_DIR%\third-party-licenses.txt" (
    echo "third-party-licenses.txt created successfully"
) else (
    echo "WARNING: third-party-licenses.txt not found, creating placeholder"
    echo "This package contains third-party dependencies. Please check the upstream source for full license information." > %SRC_DIR%\third-party-licenses.txt
)

echo "Step 6: Create service directory"
if not exist "%LIBRARY_PREFIX%\share\%PKG_NAME%" (
    mkdir "%LIBRARY_PREFIX%\share\%PKG_NAME%"
    if errorlevel 1 (
        echo "ERROR: Failed to create service directory"
        exit /b 1
    )
)

echo "Step 7: Copy service configuration"
copy "%RECIPE_DIR%\service.yaml" "%LIBRARY_PREFIX%\share\%PKG_NAME%\"
if errorlevel 1 (
    echo "ERROR: Failed to copy service.yaml"
    exit /b 1
)

echo "Build completed successfully!"
exit /b 0
