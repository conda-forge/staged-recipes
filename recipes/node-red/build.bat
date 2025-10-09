@echo on
@setlocal EnableDelayedExpansion

npm pack --ignore-scripts || goto :error
npm install -ddd ^
    --global ^
    --build-from-source ^
    %SRC_DIR%\%PKG_NAME%-%PKG_VERSION%.tgz || goto :error

:: Create license report for dependencies
pnpm install || goto :error
pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt || goto :error

mkdir %LIBRARY_PREFIX%\share\%PKG_NAME% || goto :error
xcopy %RECIPE_DIR%\service.yaml %LIBRARY_PREFIX%\share\%PKG_NAME% || goto :error

goto :eof

:error
echo Failed with error #%errorlevel%.
exit 1
