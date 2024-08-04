@echo off

pushd %SRC_DIR%\@dydxprotocol\v4-client-js
  call npm install --global --prefix %PREFIX%\lib "%PKG_NAME%-%PKG_VERSION%.tgz"
  if errorlevel 1 exit 1
popd
