set -x

export CMAKE_GENERATOR=Ninja
export CMAKE_ARGS="${CMAKE_ARGS} -DBMF_LOCAL_DEPENDENCIES=OFF -DBMF_ENABLE_CUDA=${BMF_BUILD_ENABLE_CUDA}"
"$PYTHON" -m pip install -v .

cd $PREFIX/lib/python${PY_VER}/site-packages/bmf

# Move tools into environment binary dir
rm -r cmd
rm bin/test_hmp
rm bin/hmp_perf_main
mv -v bin/* $PREFIX/bin/
rm -r bin

# Move headers into environment include dir
mv -v include/* $PREFIX/include/
rm -r include

# Move SDK module libraries into environment library dir
mv -v lib/lib* $PREFIX/lib/
mv -v BUILTIN_CONFIG.json $PREFIX/

# Move modules into environment root dir
mv -v *_modules $PREFIX/

cd lib

if [[ "$target_platform" == osx-* ]]
then
    HMP_NAME=$(ls _hmp.*)
    BMF_NAME=$(ls _bmf.*)
    install_name_tool -change @loader_path/libhmp.dylib @rpath/libhmp.dylib $HMP_NAME
    install_name_tool -change @loader_path/libhmp.dylib @rpath/libhmp.dylib $BMF_NAME
    install_name_tool -change @loader_path/libengine.dylib @rpath/libengine.dylib $BMF_NAME
    install_name_tool -change @loader_path/libbmf_module_sdk.dylib @rpath/libbmf_module_sdk.dylib $BMF_NAME
else
    patchelf --add-rpath '$ORIGIN/.' _bmf*

    # Prefer cuda-compat than system libcuda.so.1, if present
    patchelf --add-rpath $PREFIX/cuda-compat _bmf*
    for i in $(ls $PREFIX/lib/libhmp*); do
        patchelf --add-rpath $PREFIX/cuda-compat $i
    done
fi
