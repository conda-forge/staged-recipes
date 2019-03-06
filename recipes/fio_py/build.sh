export FIO_INSTALL_DIR=${PREFIX}
export FIO_ROOT=${SRC_DIR}
export FIO_ARCH=CONDA
make
make shared
make python
make install
