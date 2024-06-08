./gradlew zipKernel
CALL unzip build\distributions\ijava-*.zip
CALL python3 install.py --prefix=%PREFIX%
