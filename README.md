## About

This repo is a holding area for recipes destined for a conda-forge feedstock repo. To find out more about conda-forge, see https://github.com/conda-forge/conda-smithy.

[![Join the chat at https://gitter.im/conda-forge/conda-forge.github.io](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/conda-forge/conda-forge.github.io)


## Build status

[![Circle CI](https://circleci.com/gh/conda-forge/staged-recipes/tree/master.svg?style=shield)](https://circleci.com/gh/conda-forge/staged-recipes/tree/master) [![Build Status](https://travis-ci.org/conda-forge/staged-recipes.svg?branch=master)](https://travis-ci.org/conda-forge/staged-recipes) [![Build status](https://ci.appveyor.com/api/projects/status/3lju80dibkmowsj5/branch/master?svg=true)](https://ci.appveyor.com/project/conda-forge/staged-recipes/branch/master)

## Getting started

1. Fork this repository.
2. Make a new folder in `recipes` for your package. Look at the example recipe and our [FAQ](https://github.com/conda-forge/staged-recipes#faq) for help.
3. Open a pull request. Building of your package will be tested on Windows, Mac and Linux.
4. When your pull request is merged a new repository, called a feedstock, will be created in the github conda-forge organization, and build/upload of your package will automatically be triggered. Once complete, the package is available on conda-forge.


## FAQ

### 1. **How do I start editing the recipe?**

Look at one of [these examples](https://github.com/conda-forge/staged-recipes/tree/master/recipes)
in this repository and modify it as necessary.

Your final recipe should have no comments and follow the order in the example.

*If there are details you are not sure about please open a pull request. The conda-forge team will be happy to answer your questions.*

### 2. **How do I populate the `hash` field?**

If your package is on PyPI, you can get the md5 hash from your package's page on PyPI; look for the `md5` link next to the download link for your package.

You can also generate a hash from the command line on Linux (and Mac if you install the necessary tools below). If you go this route, the `sha256` hash is preferable to the `md5` hash.

To generate the `md5` hash: `md5 your_sdist.tar.gz`

To generate the `sha256` hash: `openssl sha256 your_sdist.tar.gz`

You may need the openssl package, available on conda-forge
`conda install openssl -c conda-forge`

### 3. **How do I exclude a platform?**

Use the `skip` key in the `build` section along with a selector:

```yaml
build:
    skip: true  # [win]
```

A full description of selectors is [in the conda docs](http://conda.pydata.org/docs/building/meta-yaml.html#preprocessing-selectors).

### 4. **What does `numpy x.x` mean?**

If you have a package which links against numpy you need to build and run against the same version of numpy.
Putting `numpy x.x` in the build and run requirements ensure that a separate package will be built for each
version of numpy that conda-forge builds against.

### 5. **What does the `build: 0` entry mean?**

The build number is used when the source code for the package has not changed but you need to make a new
build. For example, if one of the dependencies of the package was not properly specified the first time
you build a package, then when you fix the dependency and rebuild the package you should increase the build
number.

When the package version changes you should reset the build number to `0`.

### 6. **Do I have to import all of my unit tests into the recipe's `test` field?**

No, you do not.

### 7. **Do all of my package's dependencies have to be in conda(-forge) already?**

Short answer: yes. Long answer: In principle, as long as your dependencies are in at least one of
your user's conda channels they will be able to install your package. In practice, that is difficult
to manage, and we strive to get all dependencies built in conda-forge.

### 8. **When or why do I need to use `python setup.py install --single-version-externally-managed --record record.txt`?**

These options should be added to setup.py if your project uses setuptools. The goal is to prevent `setuptools` from creating an `egg-info` directory because they do not interact well with conda.

### 9. **Do I need `bld.bat` and/or `build.sh`?**

In many cases, no. Python packages almost never need it. If the build can be done with one line you can put it in the `script` line of the `build` section.

### 10. What does being a conda-forge feedstock maintainer entail?

The maintainers "job" is to:

- keep the feedstock updated by merging eventual maintenance PRs from conda-forge's bots;
- keep the package updated by bumping the version whenever there is a new release;
- answer eventual question about the package on the feedstock issue tracker.

### 11. Why are there recipes already in the `recipes` directory? Should I do something about it?

When a PR of recipe(s) is ready to go, it is merged into `master`. This will trigger a CI build specially designed to convert the recipe(s). However, for any number of reasons the recipe(s) may not be converted right away. In the interim, the recipe(s) will remain in `master` until they can be converted. There is no action required on the part of recipe contributors to resolve this. Also it should have no impact on any other PRs being proposed. If these recipe(s) pending conversion do cause issues for your submission, please ping `conda-forge/core` for help.

### 12. **Some checks failed, but it wasn't my recipe! How do I trigger a rebuild?**

Sometimes, some of the CI tools' builds fail due to no error within your recipe. If that happens, you can trigger a rebuild by re-creating the last commit and force pushing it to your branch:

```bash
# edit your last commit, giving it a new time stamp and hash
# (you can just leave the message as it is)
git commit --amend
# push to github, overwriting your branch
git push -f
```

If the problem was due to scripts in the `staged-recipes` repository, you may be asked to "rebase" once these are fixed. To do so, run:
```bash
# If you didn't add a remote for conda-forge/staged-recipes yet, also run 
# these lines:
# git remote add upstream https://github.com/conda-forge/staged-recipes.git
# git fetch --all
git rebase upstream/master
git push -f
```

