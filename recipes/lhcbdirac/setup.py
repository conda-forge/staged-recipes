import glob
import os

from setuptools import setup, find_packages


# Find the base dir where the setup.py lies
base_dir = os.path.abspath(os.path.dirname(__file__))

# Take all the packages but the scripts and tests
all_packages = find_packages(where=base_dir, exclude=['*test*', '*scripts*'])
print(all_packages)

# The scripts to be distributed
scripts = glob.glob('%s/LHCbDIRAC/*/scripts/*.py' % base_dir)
print(scripts)

setup(
    name='LHCbDIRAC',
    version='9.3.4',
    packages=all_packages,
    scripts=scripts,
    url='https://lhcb-dirac.readthedocs.io/',
    license='GPL-3.0',
    license_file='LICENSE',
    description='LHCbDIRAC is the Extension to DIRAC for the LHCb Experiment',
    install_requires=[
        'DIRAC',
    ],
)
