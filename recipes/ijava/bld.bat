./gradlew zipKernel
CALL tar -xf build\distributions\ijava-*.zip
CALL python3 install.py --prefix=%PREFIX%
