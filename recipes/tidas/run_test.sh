
mpiexec=""

if [[ "$mpi" == "mpich" ]]; then
    export HYDRA_LAUNCHER=fork
    mpiexec="mpiexec -n 2"
fi

if [[ "$mpi" == "openmpi" ]]; then
    export OMPI_MCA_btl=self,tcp
    export OMPI_MCA_plm=isolated
    export OMPI_MCA_rmaps_base_oversubscribe=yes
    export OMPI_MCA_btl_vader_single_copy_mechanism=none
    mpiexec="mpiexec --allow-run-as-root -n 2"
fi

# pipe stdout, stderr through cat to avoid O_NONBLOCK issues
eval $mpiexec python test_installed.py 2>&1 | cat
