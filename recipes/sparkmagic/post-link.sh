SP_DIR=$("${PREFIX}/bin/python" -c 'import sys, site; sys.stdout.write(site.getsitepackages()[0])')

"${PREFIX}/bin/jupyter-serverextension" enable sparkmagic --py --sys-prefix > /dev/null 2>&1
"${PREFIX}/bin/jupyter-kernelspec" install $SP_DIR/sparkmagic/kernels/sparkkernel --sys-prefix > /dev/null 2>&1
"${PREFIX}/bin/jupyter-kernelspec" install $SP_DIR/sparkmagic/kernels/pysparkkernel --sys-prefix > /dev/null 2>&1
"${PREFIX}/bin/jupyter-kernelspec" install $SP_DIR/sparkmagic/kernels/pyspark3kernel --sys-prefix > /dev/null 2>&1
"${PREFIX}/bin/jupyter-kernelspec" install $SP_DIR/sparkmagic/kernels/sparkrkernel --sys-prefix > /dev/null 2>&1
