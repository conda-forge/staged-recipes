export INSTALL_ROOT=$PREFIX

sh install.sh

mkdir -p $PREFIX/etc/conda/activate.d/
mkdir -p $PREFIX/etc/conda/deactivate.d/

cat >$PREFIX/etc/conda/activate.d/activate_sbcl.sh <<EOL
#!/bin/sh
export SBCL_HOME=\$CONDA_PREFIX/lib/sbcl
EOL

cat >$PREFIX/etc/conda/deactivate.d/deactivate_sbcl.sh <<EOL
#!/bin/sh
unset SBCL_HOME
EOL

chmod u+x $PREFIX/etc/conda/activate.d/activate_sbcl.sh
chmod u+x $PREFIX/etc/conda/deactivate.d/deactivate_sbcl.sh