if [ -z "$MACOSX_SDK_VERSION" ]; then
    export MACOSX_SDK_VERSION="@MACOSX_SDK_VERSION@"
else
    export CONDA_BACKUP_MACOSX_SDK_VERSION="${MACOSX_SDK_VERSION}"
    export MACOSX_SDK_VERSION="@MACOSX_SDK_VERSION@"
fi

if [ -z "$MACOSX_SDK_CACHE_DIR" ]; then
    export MACOSX_SDK_CACHE_DIR="${PREFIX}/MacOSX_SDKs"
else
    export CONDA_BACKUP_MACOSX_SDK_CACHE_DIR="${MACOSX_SDK_CACHE_DIR}"
fi

if [ -z "$CONDA_BUILD_SYSROOT" ]; then
    export CONDA_BUILD_SYSROOT="${MACOSX_SDK_CACHE_DIR}/MacOSX${MACOSX_SDK_VERSION}.sdk"
else
    export CONDA_BACKUP_CONDA_BUILD_SYSROOT="${CONDA_BUILD_SYSROOT}"
    export CONDA_BUILD_SYSROOT="${MACOSX_SDK_CACHE_DIR}/MacOSX${MACOSX_SDK_VERSION}.sdk"
fi

if [ -z "$SDKROOT" ]; then
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
else
    export CONDA_BACKUP_SDKROOT="${SDKROOT}"
    export SDKROOT="${CONDA_BUILD_SYSROOT}"
fi

if [ ! -d "${CONDA_BUILD_SYSROOT}" ]; then
    if [ "${MACOSX_SDK_VERSION}" = "12.3" ]; then
        url="https://github.com/alexey-lysiuk/macos-sdk/releases/download/${MACOSX_SDK_VERSION}/MacOSX${MACOSX_SDK_VERSION}.tar.xz"
    else
        url="https://github.com/phracker/MacOSX-SDKs/releases/download/11.3/MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz"
    fi
    curl -L --output "MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz" "${url}"
    mkdir -p `dirname "$CONDA_BUILD_SYSROOT"`
    tar -xf "MacOSX${MACOSX_SDK_VERSION}.sdk.tar.xz" -C `dirname "$CONDA_BUILD_SYSROOT"`
fi
