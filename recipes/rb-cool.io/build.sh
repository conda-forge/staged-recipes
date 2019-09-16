#!/bin/bash

gem install -N -l -V --norc --ignore-dependencies cool.io-1.5.4.gem
gem unpack cool.io
rm -R cool.io-1.5.4/ext/libev
make -C $PREFIX/lib/ruby/gems/${ruby}.0/gems/cool.io-1.5.4/ext/cool.io clean
make -C $PREFIX/lib/ruby/gems/${ruby}.0/gems/cool.io-1.5.4/ext/iobuffer clean
