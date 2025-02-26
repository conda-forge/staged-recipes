#!/bin/bash
set -ex

pushd HiggsAnalysis/CombinedLimit
make CONDA=1 -j${CPU_COUNT}
cp -rv build/bin ${PREFIX}
cp -v build/lib/*${SHLIB_EXT} ${PREFIX}/lib
cp -v build/lib/*.pcm ${PREFIX}/lib
cp -v build/lib/*.rootmap ${PREFIX}/lib
mkdir -p ${PREFIX}/include/HiggsAnalysis/CombinedLimit
cp -rv interface ${PREFIX}/include/HiggsAnalysis/CombinedLimit/
cp -rv build/lib/python/HiggsAnalysis $(python3 -c "import sysconfig; print(sysconfig.get_path('platlib'))")/
popd
