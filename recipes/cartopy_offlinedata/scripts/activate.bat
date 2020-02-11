:: Store existing env vars and set to this conda env
:: so other installs don't pollute the environment.

@if defined CARTOPY_OFFLINE_SHARED (
    set "_CONDA_SET_CARTOPY_OFFLINE_SHARED=%CARTOPY_OFFLINE_SHARED%"
)
@set "CARTOPY_OFFLINE_SHARED=%CONDA_PREFIX%\Library\share\cartopy"
