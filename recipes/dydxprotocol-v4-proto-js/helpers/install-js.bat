@echo off

pushd %SRC_DIR%\@dydxprotocol\v4-proto
  call npm install --global "dydxprotocol-v4-proto-%PKG_VERSION%.tgz"
  if errorlevel 1 exit 1
popd
