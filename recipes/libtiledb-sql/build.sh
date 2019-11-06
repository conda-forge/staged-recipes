#!/bin/sh
set -exo pipefail

original_dir=$PWD
export MARIADB_VERSION="mariadb-10.4.8"
mkdir tmp
shopt -s extglob
mv !(tmp) tmp # Move everything but tmp
# Use git to clone latest 10.4 to work around MDEV-20767 until 10.4.9 is release
git clone https://github.com/MariaDB/server.git -b 10.4 ${MARIADB_VERSION}

if [[ $target_platform =~ osx.* ]]; then
  export CFLAGS="${CFLAGS} -ULIBICONV_PLUG"
  export CXXFLAGS="${CXXFLAGS} -ULIBICONV_PLUG"
fi

#tar xf ${MARIADB_VERSION}.tar.gz \
# Copy LICENSE File
cp ${MARIADB_VERSION}/COPYING .
mv tmp ${MARIADB_VERSION}/storage/mytile
cd ${MARIADB_VERSION}
mkdir builddir
cd builddir
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
         -DCMAKE_PREFIX_PATH=$PREFIX \
         -DPLUGIN_TOKUDB=NO \
         -DPLUGIN_ROCKSDB=NO \
         -DPLUGIN_MROONGA=NO \
         -DPLUGIN_SPIDER=NO \
         -DPLUGIN_SPHINX=NO \
         -DPLUGIN_FEDERATED=NO \
         -DPLUGIN_FEDERATEDX=NO \
         -DPLUGIN_CONNECT=NO \
         -DPLUGIN_PERFSCHEMA=NO \
         -DPLUGIN_AUTH_PAM=NO \
         -DPLUGIN_AUTH_PAM_V1=NO \
         -DPLUGIN_AUTH_GSSAPI=NO \
         -DWITH_SSL=system \
         -DCMAKE_BUILD_TYPE=Release \
         -SWITH_DEBUG=0 \
         -DWITH_EMBEDDED_SERVER=ON \
         ..
make -j ${CPU_COUNT}
make install
