cd cling
export STDCXX=17
export VERBOSE=1
python setup.py egg_info
python create_src_directory.py

pushd src/interpreter/llvm/src/tools/clang

# Taken from https://github.com/conda-forge/clangdev-feedstock/blob/5.x/recipe/build_clangdev.sh#L8-L28

if [[ "$(uname)" == "Linux" ]]; then
  patch -p1 -i "${RECIPE_DIR}/Manually-set-linux-sysroot-for-conda.patch"
fi

if [[ "$(uname)" == "Linux" && "$cxx_compiler" == "gxx" ]]; then
    sed -i.bak -e 's@SYSROOT_PATH_TO_BE_REPLACED_WITH_SED@'"${PREFIX}/${HOST}/sysroot"'@g' \
        lib/Driver/ToolChains/Linux_sysroot.cc && rm $_.bak

    sed -i.bak -e 's@AddPath("/usr/local/include", System, false);@AddPath("'"${PREFIX}/${HOST}/sysroot/usr/include"'", System, false);@g' \
        lib/Frontend/InitHeaderSearch.cpp && rm $_.bak
fi

popd
python -m pip install . --no-deps -vv
