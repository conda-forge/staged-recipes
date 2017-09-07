:: Restore previous JCC_JDK and PATH env vars if they were set.

set "JCC_JDK="
if defined _JCC_JDK_CONDA_BACKUP (
  set "JCC_JDK=%_JCC_JDK_CONDA_BACKUP%"
  set "_JCC_JDK_CONDA_BACKUP="
)

if defined _JCC_PATH_CONDA_BACKUP (
    set "PATH =%_JCC_PATH_CONDA_BACKUP%"
    set "_JCC_PATH_CONDA_BACKUP="
)
