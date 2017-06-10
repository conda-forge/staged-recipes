make config \
    prefix="$PREFIX" \
    cc=mpicc \
    cxx=mpicxx \
    shared=1 \
    metis_path="$SRC_DIR/metis"

VERBOSE=1 make install
