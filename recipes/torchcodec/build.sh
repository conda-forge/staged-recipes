if [[ ${cuda_compiler_version} != "None" ]]; then
   export ENABLE_CUDA=1
else
   export ENABLE_CUDA=0
fi

# We explicitly depend on lgpl's variant of ffmpeg in the recipe.yaml to ensure that
# we do not have license violation due to linking a GPL project
export I_CONFIRM_THIS_IS_NOT_A_LICENSE_VIOLATION=1

pip install . --no-deps --no-build-isolation -vv
