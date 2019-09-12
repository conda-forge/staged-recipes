export GOROOT="${CONDA_BACKUP_GOROOT}"
unset CONDA_BACKUP_GOROOT
if [ -z $GOROOT ]; then
    unset GOROOT
fi
