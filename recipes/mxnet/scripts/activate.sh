if [[ "$OSTYPE" == "darwin"* ]]; then
    export MXNET_LIBRARY_PATH="$CONDA_PREFIX/lib/libmxnet.dylib"
else
    export MXNET_LIBRARY_PATH="$CONDA_PREFIX/lib/libmxnet.so"
fi

export MXNET_INCLUDE_PATH="$CONDA_PREFIX/include/mxnet"

