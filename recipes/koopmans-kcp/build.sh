# Configure
./configure MPIF90=mpifort

# Make
make kcp

# Install
make install PREFIX=${PREFIX}

# Tidy up
make clean
