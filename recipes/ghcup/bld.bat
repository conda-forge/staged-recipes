MKDIR "%LIBRARY_BIN%"
COPY ghcup.exe "%LIBRARY_BIN%"

MKDIR "%PREFIX%/etc/conda/activate.d"
echo set "GHCUP_INSTALL_BASE_PREFIX=%LIBRARY_PREFIX%" > "%PREFIX%/etc/conda/activate.d/ghcup.bat"
echo set "GHCUP_SKIP_UPDATE_CHECK=1" >> "%PREFIX%/etc/conda/activate.d/ghcup.bat"
MKDIR "%PREFIX%/etc/conda/deactivate.d"
echo set "GHCUP_INSTALL_BASE_PREFIX=" > "%PREFIX%/etc/conda/deactivate.d/ghcup.bat"
echo set "GHCUP_SKIP_UPDATE_CHECK=" >> "%PREFIX%/etc/conda/deactivate.d/ghcup.bat"