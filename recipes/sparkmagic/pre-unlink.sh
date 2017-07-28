"${PREFIX}/bin/jupyter-serverextension" disable sparkmagic --py --sys-prefix > /dev/null 2>&1

"${PREFIX}/bin/jupyter-kernelspec" uninstall -f sparkkernel
"${PREFIX}/bin/jupyter-kernelspec" uninstall -f pysparkkernel
"${PREFIX}/bin/jupyter-kernelspec" uninstall -f pyspark3kernel
"${PREFIX}/bin/jupyter-kernelspec" uninstall -f sparkrkernel
