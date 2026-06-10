#!/bin/bash -e
cmake -S ${SRC_DIR} -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBEXECDIR=libexec/cetmodules \
    -DBUILD_TESTING=OFF
cmake --build build --parallel ${CPU_COUNT} --target install

# Replace upstream symlinks with copies so the noarch package installs
# cleanly on Windows. The targets are tiny .cmake stubs.
for link in "${PREFIX}"/share/cetmodules/Modules/FindFFTW3?.cmake; do
    [ -L "${link}" ] || continue
    cp -L "${link}" "${link}.real"
    mv -f "${link}.real" "${link}"
done
