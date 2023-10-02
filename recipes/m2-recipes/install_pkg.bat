mkdir %PREFIX%\Library
xcopy %SRC_DIR%\binary-%PKG_NAME%\ %LIBRARY_PREFIX%\ /s /e /y

if "%PKG_NAME%" == "m2-file" (
  rmdir %PREFIX%\Library\usr\lib\python3.11\site-packages\__pycache__\
)

del %LIBRARY_PREFIX%\.BUILDINFO
del %LIBRARY_PREFIX%\.MTREE
del %LIBRARY_PREFIX%\.PKGINFO

if NOT "%PKG_NAME%" == "m2-msys2-launcher" (
  if NOT "%PKG_NAME%" == "m2-base" (
    if not exist %PREFIX%\Library\usr exit 1
  )
)

