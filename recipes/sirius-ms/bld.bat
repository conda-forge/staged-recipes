SET outdir=%PREFIX%\share\%PKG_NAME%-%PKG_VERSION%-%PKG_BUILDNUM%

mkdir %PREFIX%\bin
xcopy /e /k /h /i /q %cd% %outdir%
mklink %PREFIX%\bin\sirius.exe %outdir%\sirius.exe