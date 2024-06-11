./gradlew zipKernel
tar -xvf build\distributions\ijava-*.zip
"%PYTHON%" install.py --prefix="%PREFIX%"
if errorlevel 1 exit 1
