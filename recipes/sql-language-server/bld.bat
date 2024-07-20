pnpm install || goto :error
pnpm pack || goto :error

npm pack --ignore-scripts || goto :error
npm install -ddd ^
    --global ^
    --build-from-source ^
    %PKG_NAME%-%PKG_VERSION%.tgz || goto :error

goto :EOF

:error
echo Failed with error #%errorlevel%.
exit 1
