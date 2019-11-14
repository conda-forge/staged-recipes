export PETSC_DIR=${PREFIX}

# System report 
bash DAMASK_prerequisites.sh
cat system_report.txt

# Python Installation 
cp -r python/damask ${STDLIB_DIR}

# Build Damask
mkdir build
cd build 
cmake -DDAMASK_SOLVER="SPECTRAL" ..
make install
