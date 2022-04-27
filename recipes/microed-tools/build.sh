#! /bin/sh

echo "v0.1.0-dev.4-0-g134e6f3-experimental/jiffies" \
    > "${SRC_DIR}/MICROED-TOOLS-VERSION-FILE"
rm "${SRC_DIR}/VERSION"

cmake ${CMAKE_ARGS}                              \
    -DCMAKE_C_FLAGS:STRING="${CFLAGS} -Wall"     \
    -DCMAKE_CXX_FLAGS:STRING="${CXXFLAGS} -Wall" \
    "${SRC_DIR}"

cmake --build . --parallel "${CPU_COUNT}"
cmake --build . --parallel "${CPU_COUNT}" --target man
cmake --install . --prefix "${PREFIX}"

install -D                               \
    "${SRC_DIR}/README"                  \
    "${PREFIX}/share/${PKG_NAME}/README"
