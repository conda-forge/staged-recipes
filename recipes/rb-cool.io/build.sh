#!/bin/bash

GEM_NAME=${PKG_NAME/rb-/}

gem unpack ${GEM_NAME}-${PKG_VERSION}.gem
gem install -N -l -V --norc --ignore-dependencies ${GEM_NAME}-${PKG_VERSION}.gem
for e in cool.io iobuffer; do
  make -C $PREFIX/lib/ruby/gems/${ruby}.0/gems/${GEM_NAME}-${PKG_VERSION}/ext/${e} clean
done
