CPPFLAGS="-I${CONDA_PREFIX}/include"
CXXFLAGS="-L${CONDA_PREFIX}/lib"

./configure --prefix="${PREFIX}" 
make -j"${CPU_COUNT}"
make -j"${CPU_COUNT}" install
