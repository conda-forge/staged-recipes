export CNI_PATH=$CNI_PATH_BACKUP
unset CNI_PATH_BACKUP
if [ -z $CNI_PATH ]; then
    unset CNI_PATH
fi
