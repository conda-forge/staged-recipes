#!/bin/bash
set -euxo pipefail

cat > $RECIPE_DIR/gcc_shim <<"EOF"
#!/bin/sh
exec $GCC -I$PREFIX/include "$@"
EOF

chmod +x $RECIPE_DIR/gcc_shim
export CC="$RECIPE_DIR/gcc_shim"

# Re-arrange build files to match the expected layout.
ln -s $PREFIX/nvvm $PREFIX/targets/x86_64-linux/nvvm
cp $BUILD_PREFIX/targets/x86_64-linux/include/fatbinary_section.h $PREFIX/targets/x86_64-linux/include
cp $PREFIX/include/cudnn*.h $PREFIX/targets/x86_64-linux/include

echo "Installing transformer-engine"
NVTE_NO_LOCAL_VERSION=1 ${PYTHON} -m pip install .

# Remove re-arranged files.
rm -rf $PREFIX/targets/x86_64-linux/nvvm
rm -rf $PREFIX/targets/x86_64-linux/include/fatbinary_section.h
rm -rf $PREFIX/targets/x86_64-linux/include/cudnn*.h


mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/activate.sh $PREFIX/etc/conda/activate.d/transformer-engine-activate.sh

mkdir -p $PREFIX/etc/conda/deactivate.d
cp $RECIPE_DIR/deactivate.sh $PREFIX/etc/conda/deactivate.d/transformer-engine-deactivate.sh
