set -exou

mkdir -p "${PREFIX}/include/"
mkdir -p "${PREFIX}/lib"

cp -a build/include/flite "${PREFIX}/include/"
cp -P build/lib/lib*.so "${PREFIX}/lib/"
