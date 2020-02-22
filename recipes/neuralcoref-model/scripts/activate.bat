@REM Store existing neuralcoref env vars and set to this conda env
@REM so other neuralcoref installs don't pollute the environment

@if defined NEURALCOREF_CACHE (
    set "_CONDA_SET_NEURALCOREF_CACHE=%NEURALCOREF_CACHE%"
)
@set "NEURALCOREF_CACHE=%CONDA_PREFIX%\share\neuralcoref_cache"
