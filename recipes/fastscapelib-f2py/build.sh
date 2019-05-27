if [ $(uname) == Darwin ]; then
    # scikit-build doesn't support setting MACOSX_DEPLOYMENT_TARGET
    $PYTHON -m pip install . --global-option="build_ext" --global-option="--plat-name=macosx-10.9-x86_64" --no-build-isolation --no-deps --ignore-installed --no-cache-dir -vvv
else
    $PYTHON -m pip install . --no-build-isolation --no-deps --ignore-installed --no-cache-dir -vvv
fi
