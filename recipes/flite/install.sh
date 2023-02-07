set -exou

mkdir -p "${PREFIX}/lib"
cp -P build/lib/lib*.so.* "${PREFIX}/lib/"
