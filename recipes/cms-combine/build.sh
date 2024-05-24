#!/bin/bash
set -ex

pushd HiggsAnalysis/CombinedLimit
sed -i .bak 's|\${CONDA_PREFIX}|\${PREFIX}|g'  Makefile
make CONDA=1 -j${CPU_COUNT}
cp -rv build/bin ${PREFIX}
# the Makefile always uses .so as a target, so we don't use SHLIB_EXT
cp -v build/lib/*.so ${PREFIX}/lib
cp -v build/lib/*.pcm ${PREFIX}/lib
cp -v build/lib/*.rootmap ${PREFIX}/lib
mkdir -p ${PREFIX}/include/HiggsAnalysis/CombinedLimit
cp -rv interface ${PREFIX}/include/HiggsAnalysis/CombinedLimit/
cp -rv build/lib/python/HiggsAnalysis $(python3 -c "import sysconfig; print(sysconfig.get_path('platlib'))")/
popd
