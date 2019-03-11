if [[ "$CONDA_USER_PACKAGE_ISOLATION" -eq "0" ]]; then
	# Ignore python packages installed into the user's home directory
	export CONDA_PYTHONNOUSERSITE_BAK="$PYTHONNOUSERSITE"
	export PYTHONNOUSERSITE=1
	# Ignore R packages installed into the user's home directory
	export CONDA_RLIBSUSER_BAK="$R_LIBS_USER"
	export R_LIBS_USER="-"
fi

# Update activation counter
export CONDA_USER_PACKAGE_ISOLATION=$[$CONDA_USER_PACKAGE_ISOLATION+1]
