CPLUS_INCLUDE_PATH=$CONDA_PREFIX/include
export CPLUS_INCLUDE_PATH  # why is this necessary?

LIBRARY_PATH=$CONDA_PREFIX/lib
export LIBRARY_PATH

DIR_INSTALL=$PREFIX make clean swig install
