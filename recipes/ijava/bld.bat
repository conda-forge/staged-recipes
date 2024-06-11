echo on
call ./gradlew zipKernel
tar -xvf build/distributions/ijava-*.zip
dir /s
"%PYTHON%" install.py --prefix="%PREFIX%"
if errorlevel 1 exit 1
