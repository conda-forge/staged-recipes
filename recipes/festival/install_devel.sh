set -exou

mkdir -p "${PREFIX}/include/festival"
mkdir -p "${PREFIX}/lib"

cp src/lib/lib*.a "${PREFIX}/lib/"
cp src/include/*.h "${PREFIX}/include/festival/"

