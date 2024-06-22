echo on
call .\gradlew zipKernel
tar -xvf "build\distributions\ijava-%PKG_VERSION%.zip"
dir /s
echo on
"%PYTHON%" install.py --prefix="%PREFIX%"
if errorlevel 1 exit 1
