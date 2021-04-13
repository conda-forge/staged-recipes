
if [[ $target_platform =~ linux.* ]]; then  
    export LD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
else
    export DYLD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
fi
export MONO_PATH=$CONDA_PREFIX/lib
