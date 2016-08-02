./configure --prefix=$PREFIX
make
bash verify_checklib_results.sh
make install-exec
