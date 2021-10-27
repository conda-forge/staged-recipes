set -xeuo pipefail

test -x $PREFIX/bin/cadet-cli
test -x $PREFIX/bin/convertFile
test -x $PREFIX/bin/createConvBenchmark
test -x $PREFIX/bin/createLWE
test -x $PREFIX/bin/createMCLin
test -x $PREFIX/bin/createSCLang
test -x $PREFIX/bin/createSCLin
test -x $PREFIX/bin/createSCLinStep

VERSION=$($PREFIX/bin/cadet-cli --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     
        test -f $PREFIX/lib/libcadet.so.$VERSION
        test -L $PREFIX/lib/libcadet.so
        test -L $PREFIX/lib/libcadet.so.0
        ;;
    Darwin*)    
        test -f $PREFIX/lib/libcadet.$VERSION.dylib
esac
