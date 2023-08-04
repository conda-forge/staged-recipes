:: Copy contents of connector to server
xcopy connector server\libmariadb /S

:: Move to server directory
cd server

:: Git clone wsrep library
git clone https://github.com/codership/wsrep-lib.git wsrep-lib
cd wsrep-lib
git submodule update --init --recursive
git checkout e238c0d240
cd ..

:: Git clone wolfssl
git clone https://github.com/wolfSSL/wolfssl.git extra\wolfssl\wolfssl
cd extra\wolfssl\wolfssl
git submodule update --init --recursive
git checkout 4fbd4fd
cd ..\..\..

:: Git clone columnstore
git clone https://github.com/mariadb-corporation/mariadb-columnstore-engine.git storage\columnstore\columnstore
cd storage\columnstore\columnstore
git submodule update --init --recursive
git checkout 5278865
cd ..\..\..

:: Git clone rocksdb
git clone https://github.com/facebook/rocksdb.git storage\rocksdb\rocksdb
cd storage\rocksdb\rocksdb
git submodule update --init --recursive
git checkout bba5e7b
cd ..\..\..

:: Git clone libmarias3
git clone https://github.com/mariadb-corporation/libmarias3.git storage\maria\libmarias3
cd storage\maria\libmarias3
git submodule update --init --recursive
git checkout 3846890
cd ..\..\..


:: Make build directory and build
mkdir building
cd building

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake %CMAKE_ARGS% ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE="mysql_release" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_CXX_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DBUILD_CONFIG=mysql_release ^
      -DPLUGIN_AUTH_PAM=NO ^
      -DPLUGIN_OQGRAPH=NO ^
      -DPLUGIN_ROCKSDB=NO ^
      -DMYSQL_MAINTAINER_MODE=OFF ^
      -DAWS_SDK_EXTERNAL_PROJECT:BOOL=OFF ^
      ..

if errorlevel 1 exit 1
:: ctest --rerun-failed --output-on-failure
perl mysql-test\mysql-test-run.pl --suite=main --parallel=auto

if errorlevel 1 exit 1
ninja

if errorlevel 1 exit 1
ninja install