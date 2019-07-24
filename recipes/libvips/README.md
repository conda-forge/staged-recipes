<!--
# -*- mode: jinja -*-
-->

About libvips
=============

Home: https://libvips.github.io/libvips

Package license: LGPL-2.1+

Feedstock license: BSD 3-Clause

Summary: A fast image processing library with low memory needs


Notes
=====

- `openslide` support is missing, since that's in bioconda and this is a
conda-forge recipe. I suppose we'd need to move back to bioconda, or ask
for `openslide` to move to conda-forge.

- `lcms`, `libexif` support is missing.  EXIF metadata and colour management
is important. I guess we shuld make conda-forge packages for them too.

- `libgsf-1` is missing, it means no deepzoom output. Again, we'd need to
package it.

- `niftiio` is missing, I guess this is in bioconda as well.

- `openexr` is missing.

- `libheif` is missing, so no HEIC support. Again, we'd need to package
that separately.

- `orc` is missing, so there's no SIMD support. Things like convolution
will be up to about 3x slower.

- `imagemagick` is built with `jpeg`, not `libjpeg-turbo`, so we must use
`jpeg` too. This is very unfortunate. It would be good if IM could move
to turbo as well.

- I had to pin pango to 1.40.14 to get librsvg and imagemagick to go on
together.

It passes the CI tests, ie.

```
    john@kiwi:~/GIT/conda/staged-recipes (master)$ ./.circleci/run_docker_build.sh
```

completes successfully. I've not tested macOS, but it should work. It needs a
`build.bat` for win, but that should be simple.

Current build status
====================

[![Linux](https://img.shields.io/circleci/project/github/conda-forge/libvips-feedstock/master.svg?label=Linux)](https://circleci.com/gh/conda-forge/libvips-feedstock)
[![OSX](https://img.shields.io/travis/conda-forge/libvips-feedstock/master.svg?label=macOS)](https://travis-ci.org/conda-forge/libvips-feedstock)
[![Windows](https://img.shields.io/appveyor/ci/conda-forge/libvips-feedstock/master.svg?label=Windows)](https://ci.appveyor.com/project/conda-forge/libvips-feedstock/branch/master)

Current release info
====================

| Name | Downloads | Version | Platforms |
| --- | --- | --- | --- |
| [![Conda Recipe](https://img.shields.io/badge/recipe-libvips-green.svg)](https://anaconda.org/conda-forge/libvips) | [![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/libvips.svg)](https://anaconda.org/conda-forge/libvips) | [![Conda Version](https://img.shields.io/conda/vn/conda-forge/libvips.svg)](https://anaconda.org/conda-forge/libvips) | [![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/libvips.svg)](https://anaconda.org/conda-forge/libvips) |

Installing libvips
==================

Installing `libvips` from the `conda-forge` channel can be achieved by adding
`conda-forge` to your channels with:

```
conda config --add channels conda-forge
```

Once the `conda-forge` channel has been enabled, `libvips` can be installed
with:

```
conda install libvips
```

It is possible to list all of the versions of `libvips` available on your
platform with:

```
conda search libvips --channel conda-forge
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
and [TravisCI](https://travis-ci.org/) it is possible to build and upload installable
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


Updating libvips-feedstock
==========================

If you would like to improve the libvips recipe or build a new
package version, please fork this repository and submit a PR. Upon submission,
your changes will be run on the appropriate platforms to give the reviewer an
opportunity to confirm that the changes result in a successful build. Once
merged, the recipe will be re-built and uploaded automatically to the
`conda-forge` channel, whereupon the built conda packages will be available for
everybody to install and use from the `conda-forge` channel.
Note that all branches in the conda-forge/libvips-feedstock are
immediately built and any created packages are uploaded, so PRs should be based
on branches in forks and branches in the main repository should only be used to
build distinct package versions.

In order to produce a uniquely identifiable distribution:
 * If the version of a package **is not** being increased, please add or increase
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string).
 * If the version of a package **is** being increased, please remember to return
   the [``build/number``](https://conda.io/docs/user-guide/tasks/build-packages/define-metadata.html#build-number-and-string)
   back to 0.

Feedstock Maintainers
=====================

* [@jcupitt](https://github.com/jcupitt/)


