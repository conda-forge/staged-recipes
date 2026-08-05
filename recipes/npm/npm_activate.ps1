if (-not (Test-Path Env:_CONDA_NPM_PATH_BACKUP)) {
    $Env:_CONDA_NPM_PATH_BACKUP = $Env:PATH
    $Env:PATH = "$Env:CONDA_PREFIX\Library\share\npm;$Env:PATH"
}
