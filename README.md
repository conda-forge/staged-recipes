## About orange3-worldhappiness

Home: https://github.com/biolab/orange3-world-happiness

Package license: GPL-3.0-only

Feedstock license: [BSD-3-Clause](https://github.com/conda-forge/orange3-explain-feedstock/blob/master/LICENSE.txt)

Summary: Socioeconomic data add-on for Orange3

Development: https://github.com/biolab/orange3-world-happiness

Orange3 WorldHappiness is an add-on for the Orange3 data mining suite. 
It provides extensions for accessing socioeconomic datasets.

Installing orange3-worldhappiness
==========================

Installing `orange3-worldhappiness` from the `conda-forge` channel can be achieved by adding `conda-forge` to your channels with:

```
conda config --add channels conda-forge
conda config --set channel_priority strict
```

Once the `conda-forge` channel has been enabled, `orange3-worldhappiness` can be installed with:

```
conda install orange3-worldhappiness
```

It is possible to list all of the versions of `orange3-worldhappiness` available on your platform with:

```
conda search orange3-worldhappiness --channel conda-forge
```


About conda-forge
=================

[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)

conda-forge is a community-led conda channel of installable packages.
In order to provide high-quality builds, the process has been automated into the
conda-forge GitHub organization. The conda-forge organization contains one repository
for each of the installable packages. Such a repository is known as a *feedstock*.

A feedstock is made up of a conda recipe (the instructions on what and how to build
the package) and the necessary configurations for automatic building using freely
available continuous integration services. Thanks to the awesome service provided by
[CircleCI](https://circleci.com/), [AppVeyor](https://www.appveyor.com/)
and [TravisCI](https://travis-ci.com/) it is possible to build and upload installable
packages to the [conda-forge](https://anaconda.org/conda-forge)
[Anaconda-Cloud](https://anaconda.org/) channel for Linux, Windows and OSX respectively.

To manage the continuous integration and simplify feedstock maintenance
[conda-smithy](https://github.com/conda-forge/conda-smithy) has been developed.
Using the ``conda-forge.yml`` within this repository, it is possible to re-render all of
this feedstock's supporting files (e.g. the CI configuration files) with ``conda smithy rerender``.

For more information please check the [conda-forge documentation](https://conda-forge.org/docs/).

Terminology
===========

**feedstock** - the conda recipe (raw material), supporting scripts and CI configuration.

**conda-smithy** - the tool which helps orchestrate the feedstock.
                   Its primary use is in the construction of the CI ``.yml`` files
                   and simplify the management of *many* feedstocks.

**conda-forge** - the place where the feedstock and smithy live and work to
                  produce the finished article (built conda distributions)

Feedstock Maintainers
=====================

* [@NejcHirci](https://github.com/NejcHirci/)
* [@PrimozGodec](https://github.com/PrimozGodec/)
