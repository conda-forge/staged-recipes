@echo off
setlocal enableextensions enabledelayedexpansion

rename coincurve.egg-info coincurve.egg-info.dist
rename libsecp256k1 libsecp256k1.dist

rename %SRC_DIR%\coincurve\_windows_libsecp256k1.py %SRC_DIR%\coincurve\_libsecp256k1.py

set COINCURVE_UPSTREAM_REF=ddf2b2910eb19032f8dd657c66735115ae24bfba

rem Download secp256k1
curl -sLO "https://github.com/bitcoin-core/secp256k1/archive/%COINCURVE_UPSTREAM_REF%.tar.gz"
tar zxf %COINCURVE_UPSTREAM_REF%.tar.gz
mv "secp256k1-%COINCURVE_UPSTREAM_REF%" secp256k1

cd secp256k1
autogen
configure  --enable-module-recovery --enable-experimental --enable-module-ecdh --enable-module-extrakeys --enable-module-schnorrsig --enable-benchmark=no --enable-tests=no --enable-openssl-tests=no --enable-exhaustive-tests=no --enable-static --disable-dependency-tracking --with-pic
make

%PYTHON% -m pip install --use-pep517 . -vvv .
if errorlevel 1 exit 1
