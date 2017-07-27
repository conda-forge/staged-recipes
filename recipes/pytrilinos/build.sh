mkdir -p build
cd build

if [ $(uname) == Darwin ]; then
    export CXXFLAGS="-stdlib=libc++"
fi

cmake \
  -D CMAKE_BUILD_TYPE:STRING=RELEASE \
  -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX \
  -D BUILD_SHARED_LIBS:BOOL=ON \
  -D TPL_ENABLE_MPI:BOOL=ON \
  -D MPI_BASE_DIR:PATH=$PREFIX \
  -D MPI_EXEC:FILEPATH=$PREFIX/bin/mpiexec \
  -D PYTHON_EXECUTABLE:FILEPATH=$PYTHON \
  -D SWIG_EXECUTABLE:FILEPATH=$PREFIX/bin/swig \
  -D DOXYGEN_EXECUTABLE:FILEPATH=$PREFIX/bin/doxygen \
  -D Trilinos_ENABLE_Fortran:BOOL=OFF \
  -D Trilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
  -D Trilinos_ENABLE_ALL_OPTIONAL_PACKAGES:BOOL=OFF \
  -D Trilinos_ENABLE_TESTS:BOOL=OFF \
  -D Trilinos_ENABLE_EXAMPLES:BOOL=OFF \
  -D Trilinos_ENABLE_Epetra:BOOL=ON \
  -D Trilinos_ENABLE_Triutils:BOOL=ON \
  -D Trilinos_ENABLE_Tpetra:BOOL=ON \
  -D Trilinos_ENABLE_EpetraExt:BOOL=ON \
  -D Trilinos_ENABLE_Domi:BOOL=ON \
  -D Trilinos_ENABLE_Isorropia:BOOL=OFF \
  -D Trilinos_ENABLE_Pliris:BOOL=OFF \
  -D Trilinos_ENABLE_AztecOO:BOOL=ON \
  -D Trilinos_ENABLE_Galeri:BOOL=ON \
  -D Trilinos_ENABLE_Amesos:BOOL=ON \
  -D Trilinos_ENABLE_Ifpack:BOOL=ON \
  -D Trilinos_ENABLE_Komplex:BOOL=ON \
  -D Trilinos_ENABLE_ML:BOOL=ON \
  -D Trilinos_ENABLE_Anasazi:BOOL=ON \
  -D Trilinos_ENABLE_NOX:BOOL=OFF \
  -D NOX_ENABLE_LOCA:BOOL=OFF \
  -D Trilinos_ENABLE_PyTrilinos:BOOL=ON \
  -D PyTrilinos_ENABLE_TESTS:BOOL=ON \
  -D PyTrilinos_ENABLE_EXAMPLES:BOOL=ON \
  -D PyTrilinos_INSTALL_PREFIX:PATH=$PREFIX \
  $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -VV -R testTpetra_Map

make install
