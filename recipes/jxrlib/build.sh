export CPLUS_INCLUDE_PATH=$CONDA_PREFIX/include
export LIBRARY_PATH=$CONDA_PREFIX/lib

DIR_INSTALL=$PREFIX make clean swig install
