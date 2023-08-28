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

if [ ! -z "$MACOSX_SDK_VERSION" ]; then
    sdk_parts=${MACOSX_SDK_VERSION//./' '}
    sdk_parts=($sdk_parts)
    mdt_parts=${MACOSX_DEPLOYMENT_TARGET//./' '}
    mdt_parts=($mdt_parts)

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
        echo "ERROR: MACOSX_SDK_VERSION (${MACOSX_SDK_VERSION}) must be greater than or equal to MACOSX_DEPLOYMENT_TARGET (${MACOSX_DEPLOYMENT_TARGET})"
        exit 1
    fi
fi
