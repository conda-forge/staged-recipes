if "%ARCH%"=="32" (set CPU_ARCH=i686) else (set CPU_ARCH=x86_64)
%PKG_NAME%-%PKG_VERSION%-py%PY_VER%-%CPU_ARCH%.exe /userlevel=1 /S /FORCE /D=%PREFIX%
