rmdir /s /q build
mkdir build
cd build

cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -DIMGUI_BUILD_GLFW_BINDING=OFF ^
    -DIMGUI_BUILD_METAL_BINDING=OFF ^
    -DIMGUI_BUILD_OPENGL3_BINDING=OFF ^
    -DIMGUI_BUILD_WIN32_BINDING=ON ^
    -DIMGUI_BUILD_DX11_BINDING=ON ^
    -DIMGUI_FREETYPE=ON ^
    -DIMGUI_USE_WCHAR32=ON ^
    -DIMGUI_32BIT_DRAW_IDX=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1
