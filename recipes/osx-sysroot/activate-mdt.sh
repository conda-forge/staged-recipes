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

if [ -z "${MACOSX_SDK_VERSION}" ] && [ $(uname) == "Darwin" ]; then
    MACOSX_SDK_VERSION=$(xcrun --sdk macosx --show-sdk-version)
fi

if [ ! -z "$MACOSX_SDK_VERSION" ]; then
    # read version into array (default syntax uses space separation, so just replace the dots)
    sdk_parts=(${MACOSX_SDK_VERSION//'.'/' '})
    mdt_parts=(${MACOSX_DEPLOYMENT_TARGET//'.'/' '})

    # pad out to three elements with zeros
    num_sdk_parts=${#sdk_parts[@]}
    num_mdt_parts=${#mdt_parts[@]}
    for ((i=$num_sdk_parts; i<3; i++)); do
        sdk_parts[i]=0
    done
    for ((i=$num_mdt_parts; i<3; i++)); do
        mdt_parts[i]=0
    done

    # compare element by element
    error_out=0
    if [ ${sdk_parts[0]} -lt ${mdt_parts[0]} ]; then
        error_out=1
    elif [ ${sdk_parts[0]} -eq ${mdt_parts[0]} ]; then
        if [ ${sdk_parts[1]} -lt ${mdt_parts[1]} ]; then
            error_out=1
        elif [ ${sdk_parts[1]} -eq ${mdt_parts[1]} ]; then
            if [ ${sdk_parts[2]} -lt ${mdt_parts[2]} ]; then
                error_out=1
            fi
        fi
    fi

    if [ $error_out -eq 1 ]; then
        echo "ERROR: MACOSX_DEPLOYMENT_TARGET (${MACOSX_DEPLOYMENT_TARGET}) \
    must be less than or equal to the MacOS SDK version (${MACOSX_SDK_VERSION}). Set MACOSX_SDK_VERSION in the \
    conda_build_config.yaml file of your recipe to a version greater than or equal to the MACOSX_DEPLOYMENT_TARGET."
        exit 1
    fi
fi
