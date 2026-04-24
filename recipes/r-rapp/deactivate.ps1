if ($Env:CONDA_BACKUP_RAPP_INSTALL_DIR) {
    $Env:RAPP_INSTALL_DIR = $Env:CONDA_BACKUP_RAPP_INSTALL_DIR
    Remove-Item Env:\CONDA_BACKUP_RAPP_INSTALL_DIR
} else {
    Remove-Item Env:\RAPP_INSTALL_DIR -ErrorAction SilentlyContinue
}
