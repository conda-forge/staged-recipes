export OMPI_MCA_plm=isolated
export OMPI_MCA_btl=self,tcp
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export OMPI_MCA_rmaps_base_oversubscribe=yes

python testfun.py
mpirun -np 2 python testfun.py