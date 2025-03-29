set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
   export ENABLE_CUDA=1
else
   export ENABLE_CUDA=0
fi

# We explicitly depend on lgpl's variant of ffmpeg in the recipe.yaml to ensure that
# we do not have license violation due to linking a GPL project
export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

pip install . --no-deps --no-build-isolation -vv

# Remove spurious files created by gtk post-link activation script,
# that should not be included as part of the installed files
rm -f $PREFIX/lib/gdk-pixbuf-2.0/*/loaders.cache
