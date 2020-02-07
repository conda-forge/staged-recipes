echo ON

mkdir build

cmake -G "NMake Makefiles" -H. -Bbuild ^
    -DPython_FIND_STRATEGY="LOCATION" ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DCLINGO_REQUIRE_PYTHON=ON ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DPYCLINGO_INSTALL_DIR="%SP_DIR%" ^
    -DPYCLINGO_USER_INSTALL=OFF ^
    -DCLINGO_BUILD_WITH_LUA=OFF ^
    -DCLINGO_MANAGE_RPATH=OFF
if errorlevel 1 exit 1

cmake --build build --config Release
if errorlevel 1 exit 1

cmake --build build --config Release --target install
if errorlevel 1 exit 1
