#!/bin/bash
# From https://github.com/conda-forge/pytorch_sparse-feedstock/blob/main/recipe/build.sh

set -euxo pipefail

mkdir -p $PREFIX/etc/conda/activate.d
cp $RECIPE_DIR/transformer-engine-env.sh $PREFIX/etc/conda/activate.d/

if [[ ${cuda_compiler_version} != "None" && "$target_platform" == linux-64 ]]; then
    export FORCE_CUDA="1"
    if [[ ${cuda_compiler_version} == 12.6 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
    else
        echo "unsupported cuda version. edit build_pytorch.sh"
        exit 1
    fi
    # create a compiler shim because build checks whether $CC exists,
    # so we cannot pass flags in that variable; cannot use regular
    # compiler activation because nvcc doesn't understand most of the
    # flags, but we need to pass our main include directory at least.
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

fi


echo "Installing"
${PYTHON} -m pip install .
