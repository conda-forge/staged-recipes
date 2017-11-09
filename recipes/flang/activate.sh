export _OLD_LIBRARY_PATH=$LIBRARY_PATH
export _OLD_CPATH=$CPATH

if [ -z "$CONDA_PREFIX" ]; then
    export LIBRARY_PATH=$LIBRARY_PATH:$PREFIX/lib
    export CPATH=$CPATH:$PREFIX/include
else
    export LIBRARY_PATH=$LIBRARY_PATH:$CONDA_PREFIX/lib
    export CPATH=$CPATH:$CONDA_PREFIX/include
fi
