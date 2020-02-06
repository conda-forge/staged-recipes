mkdir build

cmake -G "%CMAKE_GENERATOR%" -H. -Bbuild ^
    -DPython_FIND_STRATEGY="LOCATION" ^
    -DPython_ROOT_DIR="%PREFIX%" ^
    -DCLINGO_REQUIRE_PYTHON=ON ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DPYCLINGO_INSTALL_DIR="%SP_DIR%" ^
    -DPYCLINGO_USER_INSTALL=OFF ^
    -DCLINGO_BUILD_WITH_LUA=OFF ^
    -DCLINGO_MANAGE_RPATH=OFF ^
    -DCMAKE_INSTALL_BINDIR="."

cmake --build build --config Release
cmake --build build --config Release --target install
