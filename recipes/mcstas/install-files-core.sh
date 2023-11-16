#!/usr/bin/env bash

#Make sure we fail hard in case of trouble:
set -e
set -u
set -x

SRCDIR="$PWD/src"

#A few (silent) sanity checks that variables are set and meaningful:
test -d "${PREFIX}"
test -d ${SRCDIR}
test -f ${SRCDIR}/CMakeLists.txt
test -n "${PKG_VERSION}"

for i in $(seq 1 100000); do
    #Find a unique build dir:
    BLDDIR="$PWD/build_mcstas_core_${i}"
    if [ ! -d "${BLDDIR}" ]; then
        break
    fi
done

mkdir "${BLDDIR}"
cd "${BLDDIR}"


cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -S ${SRCDIR} \
    -G "Unix Makefiles" \
    -DMCVERSION="${PKG_VERSION}" \
    -DMCCODE_BUILD_CONDA_PKG=ON \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MCSTAS=ON \
    -DMCCODE_USE_LEGACY_DESTINATIONS=OFF \
    -DBUILD_TOOLS=ON \
    -DENABLE_COMPONENTS=ON \
    -DENSURE_MCPL=OFF \
    -DENSURE_NCRYSTAL=OFF \
    -DENABLE_CIF2HKL=OFF \
    -DENABLE_NEUTRONICS=OFF \
    -DBUILD_SHARED_LIBS=ON \
    ${CMAKE_ARGS}

cmake --build . --config Release

cmake --build . --target install --config Release

test -f "${PREFIX}/bin/mcstas"
test -f "${PREFIX}/bin/mcrun"
test -f "${PREFIX}/share/mcstas/tools/Python/mccodelib/__init__.py"
test -d "${PREFIX}/share/mcstas/resources/data"

#Data files will be provided in mcstas-data package instead:
rm -rf "${PREFIX}/share/mcstas/resources/data"

#Temporary workarounds:
if [ -f "${PREFIX}/bin/postinst" ]; then
    rm -f "${PREFIX}/bin/postinst"
fi
if [ -f "${PREFIX}/bin/acc_gpu_bind" ]; then
    mv "${PREFIX}/bin/acc_gpu_bind" "${PREFIX}/bin/mcstas-acc_gpu_bind"
fi
