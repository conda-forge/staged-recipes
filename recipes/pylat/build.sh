cd ${SRC_DIR}
ls
cd src
ls
python -m numpy.f2py -c -m calccomf calcCOM.f90
python -m numpy.f2py -c -m calcdistances calcdistances.f90
python -m numpy.f2py -c -m ipcorr ipcorr.f90
#f2py -c -m src/elradial src/elradial.f90
#f2py -c -m src/siteradial src/siteradial.f90

#ln -s ipcorr.*.so ipcorr.so
#ln -s calcdistances.*.so calcdistances.so
#ln -s calccomf.*.so calccomf.so

mkdir ${PREFIX}/bin/src

cp calccomf*.so ${PREFIX}/bin/src/calccomf.so
cp calcdistances*.so ${PREFIX}/bin/src/calcdistances.so
cp ipcorr*.so ${PREFIX}/bin/src/ipcorr.so

cd ..

cp PyLAT.py ${PREFIX}/bin/.
