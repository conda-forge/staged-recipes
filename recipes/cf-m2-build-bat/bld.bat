
REM Just copy the batch and sed scripts into the Scripts folder of the conda root

copy cb_build_env_bat2sh.sed %PREFIX%\Scripts
copy cb_test_env_bat2sh.sed %PREFIX%\Scripts
copy trampoline_build_bash.bat %PREFIX%\Scripts
copy trampoline_test_bash.bat %PREFIX%\Scripts
