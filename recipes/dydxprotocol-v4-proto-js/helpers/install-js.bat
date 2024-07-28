@echo off

pushd v4-proto-js
  call npm install --global "%PKG_NAME%-%PKG_VERSION%.tgz"
  if errorlevel 1 exit 1
popd
