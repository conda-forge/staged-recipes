
wget --no-check-certificate https://pypi.io/packages/source/a/astropy-helpers/astropy-helpers-2.0.2.tar.gz

tar xvf astropy-helpers-2.0.2.tar.gz

cd astropy-helpers-2.0.2

pip install .

cd ..

# Remove bootstrap module which causes issues
# (since we already know that everything is in place before this
# script starts)

rm -rf ah_bootstrap.py
echo "" > ah_bootstrap.py

python setup.py install  --single-version-externally-managed --record=record.txt

pip uninstall -y astropy-helpers
