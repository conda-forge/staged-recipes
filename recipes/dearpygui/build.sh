set -ex

rm -rf thidparty/Microsoft
rm -rf thirdparty/gl3w
rm -rf thirdparty/glfw
rm -rf thirdparty/cpython
rm -rf thirdparty/freetype

mkdir cmake-build-local
pushd cmake-build-local

cmake -G "Ninja" ${CMAKE_ARGS} \
    -DMVDIST_ONLY=True \
    -DMVDPG_VERSION=${PKG_VERSION} \
    -DMV_PY_VERSION=${PY_VER} \
    ..

cmake --build . --config Release
popd
mkdir -p output/dearpygui
cp cmake-build-local/DearPyGui/_dearpygui.so output/dearpygui/_dearpygui.so

${PYTHON} -m pip install . -vv
