@REM Restore previous neuralcoref env vars if they were set

@set "NEURALCOREF_CACHE="
@if defined _CONDA_SET_NEURALCOREF_CACHE (
  set "NEURALCOREF_CACHE=%_CONDA_SET_NEURALCOREF_CACHE%"
  set "_CONDA_SET_NEURALCOREF_CACHE="
)
