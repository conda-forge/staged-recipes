[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/AHartmaier/pyLabDD.git/main)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/80x15.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

# pyLabDD

### Python Laboratory for Dislocation Dynamics

  - Author: Alexander Hartmaier
  - Organization: ICAMS, Ruhr University Bochum, Germany
  - Contact: <alexander.hartmaier@rub.de>

Dislocation Dynamics (DD) is a numerical method for studying
the evolution of a population of discrete dislocations in an elastic medium under mechanical loads. The pyLabDD package
introduces a simple version of Dislocation Dynamics in 2-dimensional space to study 
fundamental aspects of plastic deformation associated with the motion and mutual interaction of dislocations. Dislocations are considered as pure edge dislocations where the line direction is normal to the considered plane.

## Installation

The preferred method to use pyLabDD is within [Anaconda](https://www.anaconda.com) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html), into which it can be easily installed from [conda-forge](https://conda-forge.org) by

```
$ conda install pylabdd -c conda-forge
```

Generally, it can be installed within any 
Python environment supporting the package installer for python [pip](https://pypi.org/project/pip/) from its latest [PyPi](https://pypi.org/project/pylabdd/) image via pip

```
$ pip install pylabdd
```


Alternatively, the complete repository can be cloned and installed locally. It is recommended to create a conda environment before installation. This can be done by the following the command line instructions

```
$ git clone https://github.com/AHartmaier/pyLabDD.git ./pyLabDD
$ cd pyLabDD
$ conda env create -f environment.yml  
$ conda activate pylabdd
$ python -m pip install .
```

For this installation method, the correct implementation of the package can be tested with

```
$ pytest tests
```

After this, the package can be used within Python, e.g. be importing the entire package with

```python
import pylabdd as dd
```

## Speedup with Fortran subroutines
The subroutines to calculate the Peach-Koehler (PK) force on dislocations are rather time consuming. The Fortran implementation of these subroutines brings a considerable seepdup of the simulations compared with the pure Python version. Typically, these faster Fortran subroutines, are automatically created during installation and the embedding into Python is accomplished with the leightweight Fortran wrapper [fmodpy](https://pypi.org/project/fmodpy/). Note that this requires a gfortran compiler to be installed in the active envornment. If the compliation of the Fortran subroutines should fail, you will receive a warning and the slower Python subroutines will be used as fallback option. In that case, please check if the gfortran compiler is available. If problems still presist, please report them directly to the author of this packges or create an issue in the GitHub repo.

## Jupyter notebooks

pyLabDD is conveniently used with Jupyter notebooks. 
Available notebooks with tutorials on the dislocation dynamics method and the Taylor hardening model are contained in the subfolder `notebooks`. 

The Jupyter notebooks of the pyLabDD tutorials are also available on Binder 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/AHartmaier/pyLabDD.git/main)


## Contributions

Contributions to the pyLabDD package are highly welcome, either in form of new 
notebooks with application examples or tutorials, or in form of new functionalities 
to the Python code. Furthermore, bug reports or any comments on possible improvements of 
the code or its documentation are greatly appreciated.

## Dependencies

pyLabDD requires the following packages as imports:

 - [NumPy](http://numpy.scipy.org) for array handling
 - [MatPlotLib](https://matplotlib.org/) for graphical output
 - [fmodpy](https://pypi.org/project/fmodpy/) for embedding of faster Fortran subroutines for PK force calculation (optional)

## Version history

 - v 1.0: Initial version (with F90 subroutine)
 - v 1.1: Pure Python version (with optional F90 subroutines)
 - v 1.2: Automatic compilation of F90 subroutines with fallback to Python version

## License

The pyLabDD package comes with ABSOLUTELY NO WARRANTY. This is free
software, and you are welcome to redistribute it under the conditions of
the GNU General Public License
([GPLv3](http://www.fsf.org/licensing/licenses/gpl.html))

The contents of examples, notebooks and documentation are published under the 
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
([CC BY-NC-SA 4.0](http://creativecommons.org/licenses/by-nc-sa/4.0/))

&copy; 2025 Alexander Hartmaier, ICAMS/Ruhr University Bochum, Germany