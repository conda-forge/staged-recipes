:: Store existing env vars and set to this conda env
:: so other installs don't pollute the environment.

@if defined JCC_JDK (
    set "_JCC_JDK_CONDA_BACKUP=%JCC_JDK%"
)
set "JCC_JDK=%CONDA_PREFIX%\Library"

@set "_JCC_PATH_CONDA_BACKUP=%PATH%"
@set "PATH=%JCC_JDK%\jre\bin\server;%JCC_JDK%;%JCC_JDK%\jre\bin;%PATH%"
