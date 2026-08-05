@if not defined _CONDA_NPM_PATH_BACKUP goto :eof
@set "PATH=%_CONDA_NPM_PATH_BACKUP%"
@set "_CONDA_NPM_PATH_BACKUP="
