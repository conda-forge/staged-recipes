:: xcopy /E mariadb-connector-c server-mariadb\libmariadb\

git clone https://github.com/codership/wsrep-lib.git "server-mariadb\wsrep-lib\"
git clone https://github.com/mariadb-corporation/mariadb-connector-c.git "server-mariadb\libmariadb\"

cd server-mariadb

:: git clean -xffd
:: git submodule foreach --recursive git clean -xffd

mkdir build
cd build

:: Set INSTALL_DOCREADMEDIR to a junk path to avoid installing the README into PREFIX
cmake %CMAKE_ARGS% ^
      -GNinja ^
      -DCMAKE_BUILD_TYPE="Release" ^
      -DCMAKE_C_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_CXX_FLAGS="-I%LIBRARY_INC%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DINSTALL_DOCREADMEDIR_STANDALONE="%cd%/junk" ^
      -DINSTALL_DOCDIR="%cd%/junk" ^
      -WITH_JEMALLOC="NO" ^
      -DPLUGIN_AUTH_PAM=NO ^
      ..\cmake


if errorlevel 1 exit 1
ctest --rerun-faild --output-on-failure

ninja
if errorlevel 1 exit 1

ninja install 