export FIO_INSTALL_DIR=${PREFIX}
export FIO_ROOT=${SRC_DIR}
export FIO_ARCH=CONDA
make alldirs="m3dc1_lib fusion_io trace"
make shared
make python
make install alldirs="m3dc1_lib fusion_io trace"
