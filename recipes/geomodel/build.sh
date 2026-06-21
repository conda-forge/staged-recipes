#!/bin/bash -e

# Hide every std::__format symbol from the dynamic symbol table of every
# shared library produced here, including vtables, typeinfo, typeinfo names,
# and template-instantiated functions. libstdc++.so does not export strong
# overrides for them, so without this script the weak/vague-linkage copies
# baked into libGeoModel{Xml,Write,Read,DBManager} become the only definitions
# the dynamic linker can see; subtle libstdcxx-devel header drift between the
# geomodel build host and downstream consumers then crashes std::format users
# at runtime (ShipSoft/Geometry#26).
#
# The mangled namespace prefix `St8__format` matches every mangling form we
# need to hide:
#   _ZNSt8__format…  functions
#   _ZTVNSt8__format…  vtables
#   _ZTINSt8__format…  typeinfo
#   _ZTSNSt8__format…  typeinfo names
cat > "${SRC_DIR}/hide-std-format.ver" <<'EOF'
{
  local: *NSt8__format*;
};
EOF

cmake ${CMAKE_ARGS} -S ${SRC_DIR} -B build \
    -DCMAKE_CXX_STANDARD=20 \
    -DCMAKE_CXX_FLAGS="-fvisibility-inlines-hidden" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--version-script=${SRC_DIR}/hide-std-format.ver" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DGEOMODEL_USE_BUILTIN_JSON=OFF \
    -DGEOMODEL_USE_BUILTIN_XERCESC=OFF \
    -DGEOMODEL_USE_BUILTIN_EIGEN3=OFF \
    -DGEOMODEL_BUILD_TOOLS=ON \
    -DGEOMODEL_BUILD_GEOMODELG4=ON \
    -DGEOMODEL_BUILD_FULLSIMLIGHT=ON \
    -DGEOMODEL_BUILD_VISUALIZATION=ON \
    -DGEOMODEL_BUILD_TESTING=OFF
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
