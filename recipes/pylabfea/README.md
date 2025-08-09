[![DOI](https://zenodo.org/badge/245484086.svg)](https://zenodo.org/badge/latestdoi/245484086) 
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/AHartmaier/pyLabFEA.git/master)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/80x15.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)

# pyLabFEA

### Python Laboratory for Finite Element Analysis

  - Authors: Alexander Hartmaier, Ronak Shoghi, Jan Schmidt
  - Organization: ICAMS, Ruhr University Bochum, Germany
  - Contact: <alexander.hartmaier@rub.de>

Finite Element Analysis (FEA) is a numerical method for studying
mechanical behavior of fluids and solids. The pyLabFEA package
introduces a simple pure-python version of FEA for solid mechanics and
elastic-plastic materials. pyLabFEA can import and analyse data sets on mechanical behavior of materials following the data schema published on [GitHub](https://github.com/Ronakshoghi/MetadataSchema.git) and described in this [article](https://doi.org/10.1002/adem.202401876). Based on such data, machine learning (ML) yield functions can be trained and used as constitutive models in elasto-plastic FEA. Due to
its simplicity, pyLabFEA is well-suited for teaching, and its flexibility in
constitutive modeling of materials makes it a useful research tool for data-oriented constitutive modeling.

## Installation

The pyLabFEA package requires an [Anaconda](https://www.anaconda.com/products/individual) or [Miniconda](https://docs.conda.io/en/latest/miniconda.html) environment with a recent Python version. It can be installed from [conda-forge](https://conda-forge.org) by

```
$ conda install pylabfea
```

or from [PyPi](https://pypi.org/project/pylabfea/) via pip

```
$ pip install pylabfea
```

Alternatively, the most recent version of the complete repository, including the source code, documentation and examples, can be cloned and installed locally. It is recommended to create a conda environment before installation. This can be done by the following the command line instructions

```
$ git clone https://github.com/AHartmaier/pyLabFEA.git ./pyLabFEA
$ cd pyLabFEA
$ conda env create -f environment.yml
$ conda activate pylabfea
$ python -m pip install .
```

The correct installation with this method can be tested with

```
$ pytest tests -v
```

After this, the package can be used within python, e.g. by importing the entire package with

```python
import pylabfea as fea
```


## Documentation

Online documentation for pyLabFEA can be found under [https://ahartmaier.github.io/pyLabFEA/](https://ahartmaier.github.io/pyLabFEA/).
For offline use, open docs/index.html in your local copy to browse through the contents.
The documentation has been generated using [Sphinx](http://www.sphinx-doc.org/en/master/).

## Jupyter notebooks

pyLabFEA is conveniently used with Jupyter notebooks. 
Available notebooks with tutorials on linear and non-linear FEA, homogenization of elastic and
elastic-plastic material behavior, and constitutive models based on
machine learning algorithms are contained in the subfolder 'notebooks' of this repository and can be accessed via `index.ipynb`. An
overview on the contents of the notebooks is also available [here](https://ahartmaier.github.io/pyLabFEA/examples.html).

The Jupyter notebooks of the pyLabFEA tutorials are directly accessible on [Binder](https://mybinder.org/v2/gh/AHartmaier/pyLabFEA.git/master)

## Examples

Python routines contained in the subfolder 'examples' of this repository demonstrate how ML yield funcitons can be trained based on reference materials with significant plastic anisotropy, as Hill or Barlat reference materials, but also for isotropic J2 plasticity. The training data consists of different stress tensors that mark the onset of plastic yielding of the material. It is important that these stress tensors cover the onset of plastic yielding in the full 6-dimensional stress space, including normal and shear stresses. 

The trained ML flow rules can be used in form of a user material (UMAT) for the commercial FEA package Abaqus (Dassault Systems), as described in the README file in the subdirectory 'src/umat'.

## Contributions

Contributions to the pyLabFEA package are highly welcome, either in form of new 
notebooks with application examples or tutorials, or in form of new functionalities 
to the Python code. Furthermore, bug reports or any comments on possible improvements of 
the code or its documentation are greatly appreciated.

## Dependencies

pyLabFEA requires the following packages as imports:

 - [NumPy](http://numpy.scipy.org) for array handling
 - [Scipy](https://www.scipy.org/) for numerical solutions
 - [scikit-learn](https://scikit-learn.org/stable/) for machine learning algorithms
 - [MatPlotLib](https://matplotlib.org/) for graphical output

## Version history

 - v1: 2D finite element solver for pricipal stresses only
 - v2: Introduction of machine learning (ML) yield function
 - v3: Generalization of finite element solver and training of ML yield function to full stress tensors
 - v4: Import and analysis of microstructure-sensitive data on mechanical behavior for training and testing of ML yield function
 - v4.2: Support of strain hardening in machine learning yield function
 - v4.3: Import of data on mechanical behavior as basis for training 
 - v4.4: Support of data with crystallographic texture information

## License

The pyLabFEA package comes with ABSOLUTELY NO WARRANTY. This is free
software, and you are welcome to redistribute it under the conditions of
the GNU General Public License
([GPLv3](http://www.fsf.org/licensing/licenses/gpl.html))

The contents of examples, notebooks and documentation are published under the 
Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
([CC BY-NC-SA 4.0 DEED](http://creativecommons.org/licenses/by-nc-sa/4.0/))
