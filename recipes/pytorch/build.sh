export CMAKE_LIBRARY_PATH="$PREFIX/lib:$PREFIX/include:$CMAKE_LIBRARY_PATH"
export CMAKE_PREFIX_PATH="$PREFIX"

# static linking of libstdc++
export PYTORCH_BINARY_BUILD=1
export TH_BINARY_BUILD=1

export PYTORCH_BUILD_VERSION=$PKG_VERSION
export PYTORCH_BUILD_NUM=$PKG_BUILDNUM

export NO_CUDA=1

export MAKEFLAGS=-j$CPU_COUNT

python setup.py install --single-version-externally-managed --record record.txt
