[![PyPI version](https://badge.fury.io/py/Oasis-Optimization.svg)](https://badge.fury.io/py/Oasis-Optimization)
[![conda](https://anaconda.org/mafarrag/oasis/badges/version.svg)](https://anaconda.org/MAfarrag/oasis)
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/MAfarrag/Oasis/master)
[![Build Status](https://travis-ci.org/MAfarrag/Oasis.svg?branch=master)](https://travis-ci.org/MAfarrag/Oasis)

Oasis - Optimization Algorithm for Python 
===================================================================== 


Installation
============
```
Please install Hapi in a Virtual environment so that its requirements don't tamper with your system's python
**Oasis** works with Python 2.7 and 3.7 64Bit on Windows
```
# Install the dependencies
you can check [libraries.io](https://libraries.io/pypi/Oasis-Optimization) to check versions of the libraries
```
conda install Numpy
pip install mpi4py

```

## Install from Github
to install the last development to time you can install the library from github
```
pip install git+https://github.com/MAfarrag/Oasis.git
```
## Compile 
You can compile the repository after you clone it 
iF python is already added to your system environment variable
```
python setup.py install
```
###### or 
```
pathto_your_env\python setup.py install
```
## pip
to install the last release you can easly use pip
```
pip install Oasis-Optimization
```
## YML file
using the environment.yml file included with hapi you can create a new environment with all the dependencies installed with the latest Hapi version
in the master branch
```
conda env create --name Hapi_env -f environment.yml
```
