#!/bin/bash
set -euxo pipefail

mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/transformer-engine-env.sh $PREFIX/etc/conda/activate.d/

cat > $RECIPE_DIR/gcc_shim <<"EOF"
#!/bin/sh
exec $GCC -I$PREFIX/include "$@"
EOF

chmod +x $RECIPE_DIR/gcc_shim
export CC="$RECIPE_DIR/gcc_shim"

# Create a symlink to the nvvm directory where transformer-engine's Cmake expects it.
ln -s $PREFIX/nvvm $PREFIX/targets/x86_64-linux/nvvm
cp -n $BUILD_PREFIX/targets/x86_64-linux/include/*.h $PREFIX/targets/x86_64-linux/include
cp $PREFIX/include/cudnn*.h $PREFIX/targets/x86_64-linux/include

echo "Installing transformer-engine"
${PYTHON} -m pip install .
