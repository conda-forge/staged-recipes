if "%ARCH%"=="32" (set CPU_ARCH=i686) else (set CPU_ARCH=x86_64)

curl -fsSLO https://github.com/openturns/build-modules/releases/download/v1.14/%PKG_NAME%-%PKG_VERSION%-py%PY_VER%-%CPU_ARCH%.exe
if errorlevel 1 exit 1

%PKG_NAME%-%PKG_VERSION%-py%PY_VER%-%CPU_ARCH%.exe /userlevel=1 /S /FORCE /D=%PREFIX%
if errorlevel 1 exit 1

