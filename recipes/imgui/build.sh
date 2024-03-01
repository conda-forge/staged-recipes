set -euxo pipefail

rm -rf build || true
mkdir build
cd build

if [[ "${target_platform}" == osx* ]]; then
    OSX_BINDINGS=ON
elif [[ "${target_platform}" == linux* ]]; then
    OSX_BINDINGS=OFF
fi

cmake ${SRC_DIR} ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DIMGUI_BUILD_GLFW_BINDING=ON \
    -DIMGUI_BUILD_GLUT_BINDING=OFF \
    -DIMGUI_BUILD_METAL_BINDING=$OSX_BINDINGS \
    -DIMGUI_BUILD_OPENGL2_BINDING=ON \
    -DIMGUI_BUILD_OSX_BINDING=$OSX_BINDINGS \
    -DIMGUI_BUILD_SDL2_BINDING=ON \
    -DIMGUI_BUILD_SDL2_RENDERER_BINDING=OFF \
    -DIMGUI_BUILD_VULKAN_BINDING=OFF \
    -DIMGUI_FREETYPE=OFF \
    -DIMGUI_FREETYPE_LUNASVG=OFF \
    -DIMGUI_BUILD_ALLEGRO5_BINDING=OFF

cmake --build . --config Release -- -j$CPU_COUNT
cmake --build . --config Release --target install
