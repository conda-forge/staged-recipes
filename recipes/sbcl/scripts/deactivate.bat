:: Restore previous SBCL_HOME and PATH env vars if they were set.

@set "SBCL_HOME="
@if defined _SBCL_HOME_CONDA_BACKUP (
  @set "SBCL_HOME=%_SBCL_HOME_CONDA_BACKUP%"
  @set "_SBCL_HOME_CONDA_BACKUP="
)

@if defined _SBCL_PATH_CONDA_BACKUP (
    @set "PATH =%_SBCL_PATH_CONDA_BACKUP%"
    @set "_SBCL_PATH_CONDA_BACKUP="
)