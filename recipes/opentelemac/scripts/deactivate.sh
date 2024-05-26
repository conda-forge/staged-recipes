# Restore the original environment variables
export PATH="${OLD_PATH}"
export PYTHONPATH="${OLD_PYTHONPATH}"
export LD_LIBRARY_PATH="${OLD_LD_LIBRARY_PATH}"

# Clear the backup variables
unset OLD_PATH
unset OLD_PYTHONPATH
unset OLD_LD_LIBRARY_PATH

# $CONDA_PREFIX/bin remains in OLD_PATH and needs to be manually removed
export PATH=$(echo "$PATH" | sed "s|:$CONDA_PREFIX/bin||g; s|^$CONDA_PREFIX/bin:||g; s|:$CONDA_PREFIX/bin:|:|g")
# Optional: Echo the variables to ensure they are correctly restored
echo "Restored PATH: ${PATH}"
echo "Removed ${CONDA_PREFIX}/bin from PATH"
echo "Restored PYTHONPATH: ${PYTHONPATH}"
echo "Restored LD_LIBRARY_PATH: ${LD_LIBRARY_PATH}"
