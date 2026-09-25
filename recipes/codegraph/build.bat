call pnpm install --ignore-scripts
if %ERRORLEVEL% neq 0 exit /b 1
call npm run build
if %ERRORLEVEL% neq 0 exit /b 1

cd codegraph-kernel
call cargo build --release
if %ERRORLEVEL% neq 0 exit /b 1
cd ..

mkdir kernel
set "KERNEL_DLL="
for /r codegraph-kernel\target %%F in (codegraph_kernel.dll) do if exist "%%F" set "KERNEL_DLL=%%F"
if not defined KERNEL_DLL (
    echo error: codegraph_kernel.dll not found under codegraph-kernel\target
    exit /b 1
)
copy /Y "%KERNEL_DLL%" kernel\codegraph-kernel.node
if %ERRORLEVEL% neq 0 exit /b 1

call npm config set prefix "%PREFIX%"
if %ERRORLEVEL% neq 0 exit /b 1
call npm pack --ignore-scripts
if %ERRORLEVEL% neq 0 exit /b 1
call npm install --userconfig nonexistentrc -g colbymchenry-codegraph-%PKG_VERSION%.tgz
if %ERRORLEVEL% neq 0 exit /b 1

set "INSTALLDIR=%PREFIX%\node_modules\@colbymchenry\codegraph"
mkdir "%INSTALLDIR%\kernel"
copy /Y kernel\codegraph-kernel.node "%INSTALLDIR%\kernel\codegraph-kernel.node"
if %ERRORLEVEL% neq 0 exit /b 1

cd codegraph-kernel
call cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
if %ERRORLEVEL% neq 0 exit /b 1
cd ..
call pnpm-licenses generate-disclaimer --prod --output-file=third-party-licenses.txt
if %ERRORLEVEL% neq 0 exit /b 1
