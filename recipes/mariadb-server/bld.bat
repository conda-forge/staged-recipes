:: Copy contents of connector to server
xcopy connector server\libmariadb /S

:: Move to server directory
cd server

:: Git clone wsrep library
git clone https://github.com/codership/wsrep-lib.git server\wsrep-lib
cd wsrep-lib
git submodule update --init --recursive
cd ..

:: Make build directory and build
mkdir building
cd building

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake %CMAKE_ARGS% ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE="Release" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_CXX_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DINSTALL_DOCREADMEDIR_STANDALONE="%cd%/junk" ^
      -DINSTALL_DOCDIR="%cd%/junk" ^
      -DWITH_SAFEMALLOC=OFF ^
      -DBUILD_CONFIG=mysql_release ^
      -DPLUGIN_AUTH_PAM=NO ^
      -DPLUGIN_OQGRAPH=NO ^
      ..

if errorlevel 1 exit 1
cmake --build . --target test

if errorlevel 1 exit 1
cmake --build . --verbose