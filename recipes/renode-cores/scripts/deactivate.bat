@for %%i in ("%RENODE_CORES_PATH%") do @set "PATH=%%~dpi"

@if defined _RENODE_CORES_PATH_BACKUP (
    @set "RENODE_CORES_PATH=%_RENODE_CORES_PATH_BACKUP%"
    @set "_RENODE_CORES_PATH_BACKUP="
) else (
    @set "RENODE_CORES_PATH="
)
