export HYDRA_LAUNCHER=fork
export OMPI_MCA_plm=isolated
export OMPI_MCA_rmaps_base_oversubscribe=yes
export OMPI_MCA_btl_vader_single_copy_mechanism=none

python -X faulthandler -c "import underworld; underworld.mesh.FeMesh_Cartesian();"
pytest -vvv docs/pytests