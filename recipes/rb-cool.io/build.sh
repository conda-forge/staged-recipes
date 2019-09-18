#!/bin/bash

gem unpack ${PKG_NAME}-${PKG_VERSION}.gem
rm -R ${PKG_NAME}-${PKG_VERSION}/ext/libev
patch -d ${PKG_NAME}-${PKG_VERSION}/ext -i ${SOURCE_DIR}/unvendor_libev.patch

#TODO: Repack gem

gem install -N -l -V --norc --ignore-dependencies ${PKG_NAME}-${PKG_VERSION}.gem
for e in cool.io iobuffer; do
  make -C $PREFIX/lib/ruby/gems/${ruby}.0/gems/${PKG_NAME}-${PKG_VERSION}/ext/${e} clean
done
