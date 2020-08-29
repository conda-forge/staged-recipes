if [[ ${HOST} =~ .*linux.* ]]; then
	gfortran leparagliding.f
else
	gfortran leparagliding.f
fi
mkdir -p ${PREFIX}/bin
cp a.out ${PREFIX}/bin/leparagliding