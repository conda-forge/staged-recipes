export CGO_ENABLED="${CONDA_BACKUP_CGO_ENABLED}"
unset CONDA_BACKUP_CGO_ENABLED
if [ -z $CGO_ENABLED ]; then
    unset CGO_ENABLED
fi

export CGO_CFLAGS="${CONDA_BACKUP_CGO_CFLAGS}"
unset CONDA_BACKUP_CGO_CFLAGS
if [ -z $CGO_CFLAGS ]; then
    unset CGO_CFLAGS
fi

export CGO_CPPFLAGS="${CONDA_BACKUP_CGO_CPPFLAGS}"
unset CONDA_BACKUP_CGO_CPPFLAGS
if [ -z $CGO_CPPFLAGS ]; then
    unset CGO_CPPFLAGS
fi

export CGO_CXXFLAGS="${CONDA_BACKUP_CGO_CXXFLAGS}"
unset CONDA_BACKUP_CGO_CXXFLAGS
if [ -z $CGO_CXXFLAGS ]; then
    unset CGO_CXXFLAGS
fi

export CGO_FFLAGS="${CONDA_BACKUP_CGO_FFLAGS}"
unset CONDA_BACKUP_CGO_FFLAGS
if [ -z $CGO_FFLAGS ]; then
    unset CGO_FFLAGS
fi

export CGO_LDFLAGS="${CONDA_BACKUP_CGO_LDFLAGS}"
unset CONDA_BACKUP_CGO_LDFLAGS
if [ -z $CGO_LDFLAGS ]; then
    unset CGO_LDFLAGS
fi
