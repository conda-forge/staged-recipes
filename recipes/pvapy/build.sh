#!/bin/bash

make distclean
make configure BOOST_ROOT=${PREFIX}

echo "Generated RELEASE.local"
cat configure/RELEASE.local
echo "Generated CONFIG_SITE.local"
cat configure/CONFIG_SITE.local

make

mkdir -p "${SP_DIR}"
# pvapy builds a .so library on osx too
install -m 755 lib/python/${PY_VER}/${EPICS_HOST_ARCH}/pvaccess.so ${SP_DIR}/
