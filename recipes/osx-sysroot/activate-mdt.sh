LOCAL_MACOSX_DEPLOYMENT_TARGET="@MACOSX_DEPLOYMENT_TARGET@"

if [ -z "${MACOSX_SDK_VERSION}" ] && [ $(uname) = "Darwin" ]; then
    MACOSX_SDK_VERSION=$(xcrun --sdk macosx --show-sdk-version)
fi

if [ ! -z "$MACOSX_SDK_VERSION" ]; then
    # read version into array (default syntax uses space separation, so just replace the dots)
    # this works across zsh, sh and bash
    sdk_parts=($(sh -c "var=$MACOSX_SDK_VERSION; echo \${var//'.'/' '}"))
    mdt_parts=($(sh -c "var=$LOCAL_MACOSX_DEPLOYMENT_TARGET; echo \${var//'.'/' '}"))

    # zsh starts indexes at 1 and bash at 0
    # however both languages return an empty string for indexes out of range
    # so we loop over all of 0 1 2 3 and compare missing things as equal
    error_out=0
    for (( i=0; i<=3; ++i )); do
        if [ "${sdk_parts[$i]}" = "" ]; then
            sdk_part=0
        else
            sdk_part=${sdk_parts[$i]}
        fi

        if [ "${mdt_parts[$i]}" = "" ]; then
            mdt_part=0
        else
            mdt_part=${mdt_parts[$i]}
        fi

        if [ $sdk_part -lt $mdt_part ]; then
            error_out=1
            break
        elif [ $sdk_part -gt $mdt_part ]; then
            break
        fi
    done

    if [ $error_out -eq 1 ]; then
        echo "ERROR: MACOSX_DEPLOYMENT_TARGET (${LOCAL_MACOSX_DEPLOYMENT_TARGET}) \
must be less than or equal to the MacOS SDK version (${MACOSX_SDK_VERSION}). Set MACOSX_SDK_VERSION in the \
conda_build_config.yaml file of your recipe to a version greater than or equal to the MACOSX_DEPLOYMENT_TARGET."
        exit 1
    fi
fi

if [ -z "$MACOSX_DEPLOYMENT_TARGET" ]; then
    export MACOSX_DEPLOYMENT_TARGET="@MACOSX_DEPLOYMENT_TARGET@"
else
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_MACOSX_DEPLOYMENT_TARGET="${MACOSX_DEPLOYMENT_TARGET}"
    export MACOSX_DEPLOYMENT_TARGET="@MACOSX_DEPLOYMENT_TARGET@"
fi

if [ -z "${CMAKE_ARGS}" ]; then
    export CMAKE_ARGS="-DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
else
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_CMAKE_ARGS="${CMAKE_ARGS}"
    export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
fi

if [ -z "${CPPFLAGS}" ]; then
    export CPPFLAGS="-mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
else
    export CONDA_SYSROOT_@PLATFORM@_BACKUP_CPPFLAGS="${CPPFLAGS}"
    export CPPFLAGS="${CPPFLAGS} -mmacosx-version-min=${MACOSX_DEPLOYMENT_TARGET}"
fi
