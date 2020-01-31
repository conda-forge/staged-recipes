set -x
set -o xtrace
$R CMD INSTALL --configure-args=--with-tiledb=${CONDA_PREFIX} --install-tests --build .
