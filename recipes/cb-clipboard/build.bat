@echo on

set OPENSSL_ROOT_DIR=%PREFIX%
set OPENSSL_INCLUDE_DIR=%OPENSSL_ROOT_DIR%\include\openssl
set OPENSSL_CRYPTO_LIBRARY=%OPENSSL_ROOT_DIR%\lib\libcrypto.so.3

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=%PREFIX% ..
cmake --build . --config Release --parallel %CPU_COUNT%
cmake --install . --config Release
