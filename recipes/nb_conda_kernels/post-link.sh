{
  "${PREFIX}/bin/python" -m nb_conda_kernels.install --enable --prefix="${PREFIX}"
} >>"$PREFIX/.messages.txt" 2>&1
