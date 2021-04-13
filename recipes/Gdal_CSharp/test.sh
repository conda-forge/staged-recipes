
if [[ $target_platform =~ linux.* ]]; then  
    export DYLD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
else
    export DYLD_LIBRARY_PATH=/usr/lib:$CONDA_PREFIX/lib
fi
export MONO_PATH=$CONDA_PREFIX/lib
mono $CONDA_PREFIX/bin/gdal_test.exe