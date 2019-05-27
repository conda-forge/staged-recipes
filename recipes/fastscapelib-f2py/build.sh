if [ $(uname) == Darwin ]; then
    # directly setting MACOSX_DEPLOYMENT_TARGET is not supported by scikit-build
    $PYTHON -m pip install . \
            --global-option="--plat-name" \
            --global-option="macosx-$MACOSX_DEPLOYMENT_TARGET-$OSX_ARCH" \
            --no-build-isolation \
            --no-deps \
            --ignore-installed \
            --no-cache-dir \
            -vvv
else
    $PYTHON -m pip install . \
            --no-build-isolation \
            --no-deps \
            --ignore-installed \
            --no-cache-dir \
            -vvv
fi
