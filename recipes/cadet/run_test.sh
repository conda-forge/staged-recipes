test -x $PREFIX/bin/cadet-cli
test -x $PREFIX/bin/convertFile
test -x $PREFIX/bin/createConvBenchmark
test -x $PREFIX/bin/createLWE
test -x $PREFIX/bin/createMCLin
test -x $PREFIX/bin/createSCLang
test -x $PREFIX/bin/createSCLin
test -x $PREFIX/bin/createSCLinStep

test -f $PREFIX/lib/libcadet.so.4.1.0
test -L $PREFIX/lib/libcadet.so
test -L $PREFIX/lib/libcadet.so.0
