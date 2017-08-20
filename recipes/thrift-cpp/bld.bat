mkdir %SRC_DIR%\thirdparty\dist\winflexbison
pushd %SRC_DIR%\thirdparty\dist\winflexbison

set WIN_FLEX_BIZON_VERSION=2.4.9
set LIBEVENT_VERSION=2.1.7

curl -SLO https://github.com/lexxmark/winflexbison/releases/download/v.%WIN_FLEX_BIZON_VERSION%/win_flex_bison-%WIN_FLEX_BIZON_VERSION%.zip
7za x -y win_flex_bison-%WIN_FLEX_BIZON_VERSION%.zip
if errorlevel 1 exit 1

popd

mkdir %SRC_DIR%\thirdparty\src
pushd %SRC_DIR%\thirdparty\src

curl -SLO https://github.com/nmathewson/Libevent/archive/release-%LIBEVENT_VERSION%-rc.zip
7za x -y release-%LIBEVENT_VERSION%-rc.zip
if errorlevel 1 exit 1

cd Libevent-release-%LIBEVENT_VERSION%-rc
nmake -f Makefile.nmake
mkdir lib
move *.lib lib\
move WIN32-Code\event2\* include\event2\
move WIN32-Code\nmake\* include\event2\
move WIN32-Code\nmake\event2\* include\event2\
move *.h include\
if errorlevel 1 exit 1

popd

set BOOST_ROOT=%PREFIX%
set ZLIB_ROOT=%PREFIX%
set OPENSSL_ROOT=%PREFIX%
set OPENSSL_ROOT_DIR=%PREFIX%

cd %SRC_DIR%\build

cmake -G "%CMAKE_GENERATOR%" -DCMAKE_BUILD_TYPE=Release ^
                             -DLIBEVENT_ROOT="%SRC_DIR%\thirdparty\src\Libevent-release-%LIBEVENT_VERSION%-rc" ^
                             -DFLEX_EXECUTABLE="%SRC_DIR%\thirdparty\dist\winflexbison\win_flex.exe" ^
                             -DBISON_EXECUTABLE="%SRC_DIR%\thirdparty\dist\winflexbison\win_bison.exe" ^
                             -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
                             -DBUILD_PYTHON=OFF ^
                             -DBUILD_JAVA=OFF ^
                             -DBUILD_C_GLIB=OFF ^
                             -DWITH_SHARED_LIB=OFF "%SRC_DIR%"

cmake --build . --target install --config Release
