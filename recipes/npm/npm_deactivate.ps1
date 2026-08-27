if (Test-Path Env:_CONDA_NPM_PATH_BACKUP) {
    $Env:PATH = $Env:_CONDA_NPM_PATH_BACKUP
    Remove-Item Env:_CONDA_NPM_PATH_BACKUP
}
