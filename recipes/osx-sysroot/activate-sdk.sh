if [ -z "$MACOSX_SDK_VERSION" ]; then
    export MACOSX_SDK_VERSION="@MACOSX_SDK_VERSION@"
else
    export CONDA_MACOSX_SDK_BACKUP_MACOSX_SDK_VERSION="${MACOSX_SDK_VERSION}"
    export MACOSX_SDK_VERSION="@MACOSX_SDK_VERSION@"
fi

if [ -z "$MACOSX_SDK_CACHE_DIR" ]; then
    export MACOSX_SDK_CACHE_DIR="${PREFIX}/MacOSX_SDKs"
else
    export CONDA_MACOSX_SDK_BACKUP_MACOSX_SDK_CACHE_DIR="${MACOSX_SDK_CACHE_DIR}"
fi

if [ -z "$SDKROOT" ]; then
    export SDKROOT="${MACOSX_SDK_CACHE_DIR}/MacOSX${MACOSX_SDK_VERSION}.sdk"
else
    export CONDA_MACOSX_SDK_BACKUP_SDKROOT="${SDKROOT}"
    export SDKROOT="${MACOSX_SDK_CACHE_DIR}/MacOSX${MACOSX_SDK_VERSION}.sdk"
fi

if [ ! -d "${SDKROOT}" ]; then
    if [ "${MACOSX_SDK_VERSION}" = "1" ]; then
        unset SDKROOT
        export SDKROOT=`xcrun --show-sdk-path`
    else
        if [ "${MACOSX_SDK_VERSION}" = "12.3" ]; then
            url="https://github.com/alexey-lysiuk/macos-sdk/releases/download/${MACOSX_SDK_VERSION}/MacOSX${MACOSX_SDK_VERSION}.tar.xz"
        else
            url="https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz"
        fi
        curl -s -L --output "MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz" "${url}"
        mkdir -p `dirname "${SDKROOT}"`
        tar -xf "MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz" -C `dirname "${SDKROOT}"`
    fi
fi

if [ -z "${CMAKE_ARGS}" ]; then
    export CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT=${SDKROOT}"
else
    export CONDA_MACOSX_SDK_BACKUP_CMAKE_ARGS="${CMAKE_ARGS}"
    export CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_SYSROOT=${SDKROOT}"
fi

if [ "${CONDA_BUILD:-0}" = "1" ]; then
    if [ -z "$CONDA_BUILD_SYSROOT" ]; then
        export CONDA_BUILD_SYSROOT="${SDKROOT}"
    else
        export CONDA_MACOSX_SDK_BACKUP_CONDA_BUILD_SYSROOT="${CONDA_BUILD_SYSROOT}"
        export CONDA_BUILD_SYSROOT="${SDKROOT}"
    fi
fi
