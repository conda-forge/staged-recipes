#!/bin/sh
./gradlew zipKernel
unzip build/distributions/ijava-*.zip
python3 install.py --prefix="${PREFIX}"
