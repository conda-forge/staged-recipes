if [ -z "${CONDA_BACKUP_MACOSX_SDK_VERSION}" ]; then
    export MACOSX_SDK_VERSION="${CONDA_BACKUP_MACOSX_SDK_VERSION}"
    unset CONDA_BACKUP_MACOSX_SDK_VERSION
else
    unset MACOSX_SDK_VERSION
fi

if [ -z "${CONDA_BACKUP_MACOSX_SDK_CACHE_DIR}" ]; then
    # we didn't override this so no need to reset
    # backup var is here to indicate to not unset
    unset CONDA_BACKUP_MACOSX_SDK_CACHE_DIR
else
    unset MACOSX_SDK_CACHE_DIR
fi

if [ -z "${CONDA_BACKUP_CONDA_BUILD_SYSROOT}" ]; then
    export CONDA_BUILD_SYSROOT="${CONDA_BACKUP_CONDA_BUILD_SYSROOT}"
    unset CONDA_BACKUP_CONDA_BUILD_SYSROOT
else
    unset CONDA_BUILD_SYSROOT
fi

if [ -z "${CONDA_BACKUP_SDKROOT}" ]; then
    export SDKROOT="${CONDA_BACKUP_SDKROOT}"
    unset CONDA_BACKUP_SDKROOT
else
    unset SDKROOT
fi
