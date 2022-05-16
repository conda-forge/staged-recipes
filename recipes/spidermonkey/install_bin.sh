cd obj

cp js/src/build/js-config js/src/build/js$MAJORVERSION-config
./config/nsinstall -t js/src/build/js$MAJORVERSION-config $PREFIX/bin

cp dist/bin/js dist/bin/js$MAJORVERSION
./config/nsinstall -t dist/bin/js$MAJORVERSION $PREFIX/bin