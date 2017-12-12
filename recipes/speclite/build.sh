# Speclite needs the astropy-helpers package for building, which however is not meant to be
# present at runtime.
# Instead of creating another conda recipe for it, we can just
# get it at build time, use it, and then remove it so that it does not become
# part of the package

wget --no-check-certificate https://pypi.io/packages/source/a/astropy-helpers/astropy-helpers-2.0.2.tar.gz

tar xvf astropy-helpers-2.0.2.tar.gz

cd astropy-helpers-2.0.2

pip install .

cd ..

# Remove bootstrap module which causes issues because it tries to
# check for updates to the astropy-helpers module, and fails because
# python is not allowed to get on the internet within a conda build

rm -rf ah_bootstrap.py
echo "" > ah_bootstrap.py

python setup.py install  --single-version-externally-managed --record=record.txt

# We do not need astropy-helpers anymore, let's remove it so that it does not become
# part of the package

pip uninstall -y astropy-helpers
