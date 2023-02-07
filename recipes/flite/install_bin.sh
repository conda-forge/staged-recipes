set -exou

mkdir -p "${PREFIX}/bin"

cp build/bin/flite* ${PREFIX}/bin/
cp bin/t2p ${PREFIX}/bin/
