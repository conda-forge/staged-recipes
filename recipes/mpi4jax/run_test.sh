export OMPI_MCA_plm=isolated
export OMPI_MCA_btl=self,tcp
export OMPI_MCA_btl_vader_single_copy_mechanism=none
export OMPI_MCA_rmaps_base_oversubscribe=yes

if [ $(uname) == Darwin ]; then
	echo "127.0.0.1 $(sudo scutil --get LocalHostName).local" | sudo tee -a /etc/hosts
	cat /etc/hosts
	sleep 10
fi

echo "no mpirun"
python testfun.py

echo "mpirun"
mpirun -np 2 python testfun.py